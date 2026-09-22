Yes. In fact, for your DevOps project, I would **not document the SonarQube server as a manual-only installation**. We can convert the whole setup into Terraform so you can recreate it consistently.

The important distinction is:

> **Terraform should provision the AWS infrastructure. Configuration management should install/configure SonarQube inside the EC2 instance.**

For your lab, we can still use Terraform to automate both using `user_data`/cloud-init, but I recommend separating the layers.

## Target Terraform architecture

```text
                    Terraform
                       |
          +------------+-------------+
          |                          |
          v                          v
       AWS VPC                    EC2
                                    |
                           +--------+--------+
                           |                 |
                       EBS 50 GB          Security Group
                           |                 |
                           v                 |
                         RHEL 9              |
                           |                 |
                  +--------+---------+       |
                  |                  |       |
              LVM Root          LVM 20 GB    |
                  |                  |        |
                  |                  v        |
                  |            /opt/sonarqube |
                  |                  |        |
                  |             SonarQube      |
                  |               :9000 <------+
                  |
                  v
              PostgreSQL
                 :5432
```

For your existing setup, Terraform would manage:

1. EC2 instance
2. Security Group
3. EBS/root disk
4. User-data bootstrap
5. LVM configuration
6. Java 21
7. PostgreSQL 16
8. SonarQube database
9. SonarQube user
10. SonarQube installation
11. SonarQube configuration
12. systemd service
13. Port 9000

---

# Recommended Terraform project structure

Since you're already building your AWS/DevOps repository, I would create:

```text
my-AWS-DevOps-Project/
│
├── 10-k8s-tf-EKS-Dev-infra/
│
├── 8-Jenkins/
│
└── 9-SonarQube/
    │
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── providers.tf
    ├── terraform.tfvars
    │
    ├── user-data/
    │   └── sonarqube.sh
    │
    └── README.md
```

This is much cleaner than putting SonarQube Terraform into your EKS Terraform.

---

# Step 1 — Terraform provider

Create:

```text
9-SonarQube/providers.tf
```

```hcl
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
```

---

# Step 2 — Variables

`variables.tf`

```hcl
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "SonarQube EC2 instance type"
  type        = string
  default     = "t2.medium"
}

variable "sonarqube_port" {
  description = "SonarQube web port"
  type        = number
  default     = 9000
}

variable "allowed_cidr" {
  description = "CIDR allowed to access SonarQube"
  type        = string
}
```

Your `terraform.tfvars`:

```hcl
aws_region    = "us-east-1"
instance_type = "t2.medium"

allowed_cidr = "YOUR_PUBLIC_IP/32"
```

Don't commit your actual public IP if you don't want it in Git.

---

# Step 3 — Security Group

`main.tf`

```hcl
resource "aws_security_group" "sonarqube" {
  name        = "sonarqube-sg"
  description = "Security group for SonarQube"

  ingress {
    description = "SonarQube"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sonarqube-sg"
  }
}
```

For a real environment, we'd tighten SSH access further.

---

# Step 4 — Find the RHEL AMI

Don't hard-code an AMI ID because AMIs vary by region and change over time.

For your lab, we can use an AWS data source:

```hcl
data "aws_ami" "rhel" {
  most_recent = true

  owners = ["309956199498"]

  filter {
    name   = "name"
    values = ["RHEL-9.*_HVM-*-x86_64-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}
```

Then:

```hcl
output "rhel_ami_id" {
  value = data.aws_ami.rhel.id
}
```

We should verify the AMI naming against the current RHEL AWS catalog before applying this in your account.

---

# Step 5 — EC2 instance

```hcl
resource "aws_instance" "sonarqube" {
  ami           = data.aws_ami.rhel.id
  instance_type = var.instance_type

  vpc_security_group_ids = [
    aws_security_group.sonarqube.id
  ]

  user_data = templatefile(
    "${path.module}/user-data/sonarqube.sh",
    {
      sonarqube_version = "26.9.0.129388"
    }
  )

  root_block_device {
    volume_size = 50
    volume_type = "gp3"

    encrypted = true

    tags = {
      Name = "sonarqube-root"
    }
  }

  tags = {
    Name        = "sonarqube"
    Environment = "dev"
    Application = "sonarqube"
  }
}
```

But there's an important issue here.

Your existing manual installation uses:

```text
50 GB EBS
       |
       v
      LVM
       |
       +---- 6 GB /
       |
       +---- 20 GB /opt/sonarqube
```

Terraform's `root_block_device` only gives us the disk. **It does not automatically create your LVM layout.**

Therefore, we'll create the LVM inside `user-data`.

---

# Step 6 — Automate your LVM layout

This is where your current manual work becomes automation.

Your manual process was:

```bash
sudo lvcreate -L 20G -n sonarqubeVol RootVG
sudo mkfs.xfs /dev/RootVG/sonarqubeVol
sudo mkdir -p /opt/sonarqube
sudo mount /dev/RootVG/sonarqubeVol /opt/sonarqube
```

We can automate that.

Example:

```bash
#!/bin/bash

set -e

dnf install -y lvm2 xfsprogs

if ! lvs RootVG/sonarqubeVol >/dev/null 2>&1; then
    lvcreate -L 20G -n sonarqubeVol RootVG
    mkfs.xfs /dev/RootVG/sonarqubeVol
fi

mkdir -p /opt/sonarqube

UUID=$(blkid -s UUID -o value /dev/RootVG/sonarqubeVol)

if ! grep -q "$UUID" /etc/fstab; then
    echo "UUID=$UUID /opt/sonarqube xfs defaults 0 0" >> /etc/fstab
fi

mount -a
```

This reproduces the storage part of your current server.

---

# Step 7 — Install Java 21

Inside `sonarqube.sh`:

```bash
dnf install -y java-21-openjdk java-21-openjdk-devel
```

Then:

```bash
java --version
```

---

# Step 8 — Install PostgreSQL 16

```bash
dnf module reset postgresql -y
dnf module enable postgresql:16 -y

dnf install -y postgresql-server postgresql-contrib

postgresql-setup --initdb

systemctl enable --now postgresql
```

---

# Step 9 — Configure PostgreSQL authentication

Terraform itself shouldn't manage database credentials in plaintext.

For a lab, we can use a bootstrap-generated password.

For a better design:

```text
AWS Secrets Manager
        |
        v
Terraform
        |
        v
EC2 user-data
        |
        v
PostgreSQL
```

Later we can move the password to **AWS Secrets Manager**.

---

# Step 10 — Create SonarQube DB

Bootstrap script:

```bash
sudo -u postgres psql <<EOF
CREATE USER sonarqube WITH PASSWORD '${SONARQUBE_DB_PASSWORD}';
CREATE DATABASE sonarqube OWNER sonarqube;
GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonarqube;
EOF
```

Then configure:

```text
/var/lib/pgsql/data/pg_hba.conf
```

with:

```text
host    all    all    127.0.0.1/32    scram-sha-256
host    all    all    ::1/128         scram-sha-256
```

---

# Step 11 — Linux kernel configuration

Exactly what we did manually:

```bash
cat > /etc/sysctl.d/99-sonarqube.conf <<EOF
vm.max_map_count=524288
fs.file-max=131072
EOF

sysctl --system
```

And:

```bash
cat > /etc/security/limits.d/99-sonarqube.conf <<EOF
sonarqube   -   nofile   131072
sonarqube   -   nproc    8192
EOF
```

---

# Step 12 — Create SonarQube user

```bash
useradd --system --create-home --shell /bin/bash sonarqube
```

---

# Step 13 — Download SonarQube

The exact version you're using:

```text
26.9.0.129388
```

URL:

```text
https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-26.9.0.129388.zip
```

Bootstrap:

```bash
curl -fL \
  -o /tmp/sonarqube.zip \
  https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-26.9.0.129388.zip
```

Extract:

```bash
dnf install -y unzip rsync

unzip -q /tmp/sonarqube.zip -d /tmp/

rsync -a \
  /tmp/sonarqube-26.9.0.129388/ \
  /opt/sonarqube/
```

Then:

```bash
chown -R sonarqube:sonarqube /opt/sonarqube
```

And:

```bash
find /opt/sonarqube/bin \
  -type f \
  -name "*.sh" \
  -exec chmod +x {} \;
```

---

# Step 14 — Configure SonarQube

Terraform/user-data generates:

```text
/opt/sonarqube/conf/sonar.properties
```

with:

```properties
sonar.jdbc.username=sonarqube
sonar.jdbc.password=${SONARQUBE_DB_PASSWORD}
sonar.jdbc.url=jdbc:postgresql://127.0.0.1:5432/sonarqube

sonar.web.port=9000
```

---

# Step 15 — systemd

Your Terraform bootstrap can create:

```text
/etc/systemd/system/sonarqube.service
```

```ini
[Unit]
Description=SonarQube Service
After=network.target postgresql.service
Requires=postgresql.service

[Service]
Type=forking
User=sonarqube
Group=sonarqube

ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop

LimitNOFILE=131072
LimitNPROC=8192

Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Then:

```bash
systemctl daemon-reload
systemctl enable sonarqube
systemctl start sonarqube
```

---

# Step 16 — Terraform outputs

`outputs.tf`:

```hcl
output "sonarqube_public_ip" {
  value = aws_instance.sonarqube.public_ip
}

output "sonarqube_url" {
  value = "http://${aws_instance.sonarqube.public_ip}:9000"
}
```

After:

```bash
terraform apply
```

you'll get:

```text
sonarqube_public_ip = "x.x.x.x"

sonarqube_url = "http://x.x.x.x:9000"
```

---

# But I recommend one improvement

For your **learning project**, start with:

```text
Terraform
    |
    +-- EC2
    +-- Security Group
    +-- EBS
    |
    +-- user_data
           |
           +-- LVM
           +-- Java
           +-- PostgreSQL
           +-- SonarQube
           +-- systemd
```

Once you understand that, move to the more production-like model:

```text
Terraform
    |
    +-- VPC
    +-- EC2
    +-- EBS
    +-- Security Group
    +-- IAM
    +-- Secrets Manager
    |
    v
Ansible
    |
    +-- Java
    +-- PostgreSQL
    +-- SonarQube
    +-- systemd
```

**Terraform provisions infrastructure; Ansible/configuration management installs and configures software.**

For your current Roboshop project, I'd build **`9-SonarQube` as a complete Terraform module**, including the EC2, SG, 50-GB EBS/LVM layout, Java 21, PostgreSQL 16, SonarQube 26.9, systemd and outputs. This will give you a genuinely reusable installation rather than just a list of manual commands.
