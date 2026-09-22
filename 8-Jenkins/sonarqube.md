### Suggested document structure
    I recommend documenting it as a **RHEL 9.7 + SonarQube 26.9 + PostgreSQL 16 + Java 21** installation guide, with a separate troubleshooting section.
###############
RHEL 9
 │
 ├── Java
 │
 ├── PostgreSQL
 │     └── sonarqube database
 │
 ├── Linux kernel settings
 │
 ├── sonarqube user
 │
 ├── /opt/sonarqube
 │
 ├── SonarQube
 │
 └── systemd service
 │       └── :9000
 │
 └── Jenkins integration
# SonarQube Installation Guide — RHEL 9

## 1. Environment

| Component            | Configuration         |
| -------------------- | --------------------- |
| OS                   | RHEL 9.7              |
| Instance             | AWS EC2 `t2.medium`   |
| CPU                  | 2 vCPU                |
| RAM                  | ~3.6 GiB available    |
| Swap                 | 2 GiB                 |
| SonarQube            | 26.9.0.129388         |
| Java                 | OpenJDK 21.0.12.1 LTS |
| Database             | PostgreSQL 16.15      |
| SonarQube DB         | `sonarqube`           |
| SonarQube DB User    | `sonarqube`           |
| SonarQube filesystem | 20 GB XFS             |
| Mount point          | `/opt/sonarqube`      |
| Web port             | 9000                  |

---

# 2. Storage Preparation

### Check disks

```bash
lsblk
df -h
```

### Create SonarQube LVM volume

```bash
sudo lvcreate -L 20G -n sonarqubeVol RootVG
```

### Format as XFS

```bash
sudo mkfs.xfs /dev/RootVG/sonarqubeVol
```

### Create mount point

```bash
sudo mkdir -p /opt/sonarqube
```

### Mount

```bash
sudo mount /dev/RootVG/sonarqubeVol /opt/sonarqube
```

### Get UUID

```bash
sudo blkid /dev/RootVG/sonarqubeVol
```

### Persistent mount

Add to `/etc/fstab`:

```text
UUID=<SONARQUBE_VOLUME_UUID> /opt/sonarqube xfs defaults 0 0
```

Test:

```bash
sudo umount /opt/sonarqube
sudo mount -a
df -h /opt/sonarqube
```

Expected:

```text
/dev/mapper/RootVG-sonarqubeVol   20G   ...   /opt/sonarqube
```

---

# 3. Java Installation

Install Java 21:

```bash
sudo dnf install -y java-21-openjdk java-21-openjdk-devel
```

Verify:

```bash
java --version
which java
readlink -f "$(which java)"
```

Example:

```text
openjdk 21.0.12.1 LTS
```

---

# 4. PostgreSQL Installation

Check available PostgreSQL versions:

```bash
sudo dnf list --available 'postgresql*'
sudo dnf module list postgresql
```

Select PostgreSQL 16:

```bash
sudo dnf module reset postgresql -y
sudo dnf module enable postgresql:16 -y
```

Install:

```bash
sudo dnf install -y postgresql-server postgresql-contrib
```

Verify:

```bash
psql --version
```

Initialize:

```bash
sudo postgresql-setup --initdb
```

Enable and start:

```bash
sudo systemctl enable --now postgresql
```

Verify:

```bash
sudo systemctl status postgresql --no-pager
```

---

# 5. PostgreSQL Authentication

Edit:

```bash
sudo vi /var/lib/pgsql/data/pg_hba.conf
```

Configure localhost TCP authentication:

```text
host    all    all    127.0.0.1/32    scram-sha-256
host    all    all    ::1/128         scram-sha-256
```

Reload:

```bash
sudo systemctl reload postgresql
```

---

# 6. Create SonarQube Database

Enter PostgreSQL:

```bash
sudo -u postgres psql
```

Create user:

```sql
CREATE USER sonarqube WITH PASSWORD '<STRONG_PASSWORD>';
```

Create database:

```sql
CREATE DATABASE sonarqube OWNER sonarqube;
```

Grant privileges:

```sql
GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonarqube;
```

Exit:

```sql
\q
```

Test:

```bash
psql -h 127.0.0.1 -U sonarqube -d sonarqube
```

Verify:

```sql
SELECT current_database(), current_user;
```

Expected:

```text
sonarqube | sonarqube
```

---

# 7. Linux Kernel Configuration

Create:

```bash
sudo tee /etc/sysctl.d/99-sonarqube.conf > /dev/null <<'EOF'
vm.max_map_count=524288
fs.file-max=131072
EOF
```

Apply:

```bash
sudo sysctl --system
```

Verify:

```bash
sysctl vm.max_map_count
sysctl fs.file-max
```

Expected:

```text
vm.max_map_count = 524288
fs.file-max = 131072
```

---

# 8. SonarQube User

Create service user:

```bash
sudo useradd --system --create-home --shell /bin/bash sonarqube
```

If it already exists:

```text
useradd: user 'sonarqube' already exists
```

that's okay.

Verify:

```bash
id sonarqube
```

---

# 9. Process Limits

Create:

```bash
sudo tee /etc/security/limits.d/99-sonarqube.conf > /dev/null <<'EOF'
sonarqube   -   nofile   131072
sonarqube   -   nproc    8192
EOF
```

Verify:

```bash
cat /etc/security/limits.d/99-sonarqube.conf
```

---

# 10. Download SonarQube

Official distribution used in this installation:

```text
SonarQube 26.9.0.129388
```

Download:

```bash
mkdir -p ~/sonarqube-install
cd ~/sonarqube-install

curl -fL -o sonarqube-26.9.0.129388.zip \
https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-26.9.0.129388.zip
```

---

# 11. Install SonarQube

Extract:

```bash
sudo unzip -q sonarqube-26.9.0.129388.zip -d /opt/
```

Copy installation into the dedicated filesystem:

```bash
sudo rsync -a /opt/sonarqube-26.9.0.129388/ /opt/sonarqube/
```

Remove temporary extracted directory:

```bash
sudo rm -rf /opt/sonarqube-26.9.0.129388
```

Set ownership:

```bash
sudo chown -R sonarqube:sonarqube /opt/sonarqube
```

Verify:

```bash
df -h /opt/sonarqube
ls -la /opt/sonarqube
```

---

# 12. Fix SonarQube Script Permissions

Verify:

```bash
find /opt/sonarqube/bin -name sonar.sh -type f -ls
```

Make scripts executable:

```bash
sudo find /opt/sonarqube/bin -type f -name "*.sh" -exec chmod +x {} \;
```

Verify:

```bash
ls -l /opt/sonarqube/bin/linux-x86-64/sonar.sh
```

Expected:

```text
-rwxr-xr-x
```

---

# 13. Configure SonarQube

Edit:

```bash
sudo vi /opt/sonarqube/conf/sonar.properties
```

Configure:

```properties
sonar.jdbc.username=sonarqube
sonar.jdbc.password=<STRONG_PASSWORD>
sonar.jdbc.url=jdbc:postgresql://127.0.0.1:5432/sonarqube

sonar.web.port=9000
```

Set ownership again:

```bash
sudo chown -R sonarqube:sonarqube /opt/sonarqube
```

---

# 14. Test SonarQube Manually

Start:

```bash
sudo -u sonarqube /opt/sonarqube/bin/linux-x86-64/sonar.sh console
```

Check port:

```bash
sudo ss -tlnp | grep 9000
```

Expected:

```text
LISTEN ... *:9000 ...
```

Check API:

```bash
curl -s http://127.0.0.1:9000/api/system/status
```

---

# 15. Systemd Service

After successful manual startup, create:

```bash
sudo vi /etc/systemd/system/sonarqube.service
```

Use:

```ini
[Unit]
Description=SonarQube Service
After=network.target postgresql.service

[Service]
Type=forking
User=sonarqube
Group=sonarqube

ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop

LimitNOFILE=131072
LimitNPROC=8192
Restart=always

[Install]
WantedBy=multi-user.target
```

Then:

```bash
sudo systemctl daemon-reload
sudo systemctl enable sonarqube
sudo systemctl start sonarqube
```

Check:

```bash
sudo systemctl status sonarqube --no-pager
```

---

# 16. AWS Security Group

Add inbound rule:

| Protocol | Port | Source        |
| -------- | ---: | ------------- |
| TCP      | 9000 | Your IP `/32` |

Then access:

```text
http://<EC2-PUBLIC-IP>:9000
```

For your current server:

```text
http://3.95.25.162:9000
```

---

# 17. Troubleshooting Commands

### SonarQube service

```bash
sudo systemctl status sonarqube --no-pager -l
```

### SonarQube logs

```bash
sudo tail -100 /opt/sonarqube/logs/sonar.log
```

```bash
sudo tail -100 /opt/sonarqube/logs/web.log
```

```bash
sudo tail -100 /opt/sonarqube/logs/es.log
```

### PostgreSQL

```bash
sudo systemctl status postgresql --no-pager
```

### Port

```bash
sudo ss -tlnp | grep 9000
```

### Process

```bash
ps -ef | grep -i '[s]onar'
```

### Disk

```bash
df -h /opt/sonarqube
```

### Kernel setting

```bash
sysctl vm.max_map_count
```

---

## 18. Final Architecture

```text
                         Internet
                            |
                            | TCP 9000
                            |
                     AWS Security Group
                            |
                            v
                +------------------------+
                |      EC2 t2.medium     |
                |        RHEL 9.7        |
                |                        |
                |     SonarQube 26.9     |
                |          :9000         |
                |             |          |
                |             v          |
                |      PostgreSQL 16     |
                |        :5432           |
                |             |          |
                |             v          |
                |      sonarqube DB      |
                +------------------------+
                         |
                         |
                 /opt/sonarqube
                    20 GB XFS
```

### Jenkins integration — next phase

Once the standalone server is documented, your eventual CI/CD flow will be:

```text
Developer
    |
    v
GitHub
    |
    v
Jenkins Agent
    |
    +---- Build
    |
    +---- Test
    |
    +---- SonarQube Scanner
              |
              v
         SonarQube
              |
              v
         Quality Gate
              |
       +------+------+
       |             |
     PASS           FAIL
       |             |
       v             v
   Docker Build    Stop
       |
       v
      ECR
       |
       v
      EKS
```

**For your future-installation document, I strongly recommend keeping the database password as `<STRONG_PASSWORD>` rather than saving the actual password in the document.** Also record the exact SonarQube version (`26.9.0.129388`) so a future reinstall doesn't accidentally use a different release.
