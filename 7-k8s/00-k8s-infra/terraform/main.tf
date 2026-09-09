resource "aws_instance" "workstation" {
  ami           = local.ami_id
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.workstation.id]
  user_data = templatefile("workstation.sh.tftpl", {
    aws_access_key = var.aws_access_key
    aws_secret_key = var.aws_secret_key
  })

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
    # EBS volume tags
    tags = merge(
      {
          Name = "${var.project}-${var.environment}-workstation"
      },
    local.common_tags
    )
  }

  tags = merge(
    {
        Name = "${var.project}-${var.environment}-workstation"
    },
    local.common_tags
  )
}

resource "aws_security_group" "workstation" {
  name        = "allow-all-workstation" # this is for AWS account
  description = "Allow TLS inbound traffic and all outbound traffic"

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      =  ["${chomp(data.http.my_public_ip.response_body)}/32"]
  }

  tags = merge(
    {
        Name = "${var.project}-${var.environment}-workstation"
    },
    local.common_tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "terraform_data" "cluster_destroy" {
  input = {
    host     = aws_instance.workstation.public_ip
    password = var.ssh_password
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "eksctl delete cluster -f /home/ec2-user/my-AWS-DevOps-Project/7-k8s/00-k8s-infra/eksctl/eksctl.yaml --wait"
    ]
    
    connection {
      type     = "ssh"
      host     = self.input.host
      user     = "ec2-user"
      password = self.input.password
    }
  }
}

output "workstation_public_ip" {
  value = aws_instance.workstation.public_ip
}
##########
# Resource to execute the validation commands sequentially after cluster infrastructure is ready
resource "null_resource" "cluster_verification" {
  
  # Optional: Ensures these run only after your EKS cluster and nodegroup resources are fully created
  # depends_on = [aws_eks_cluster.roboshop, aws_eks_node_group.managed]

  # Command 1: Configure kubectl local context
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region us-east-1 --name roboshop"
  }

  # Command 2: Verify overall cluster health status
  provisioner "local-exec" {
    command = "aws eks describe-cluster --region us-east-1 --name roboshop --query 'cluster.status'"
  }

  # Command 3: Fetch the active status of the managed nodegroups
  provisioner "local-exec" {
    command = "eksctl get nodegroup --cluster roboshop --region us-east-1"
  }

  # Command 4: Print out the final connected Kubernetes nodes
  provisioner "local-exec" {
    command = "kubectl get nodes"
  }
}

# Plain output description to guide you on how to check your cluster setup manually
output "next_steps_verification" {
  value = <<EOT
======================================================================
CLUSTER DEPLOYMENT COMPLETE
Your cluster context has been updated automatically. 
If your nodes are still initializing, run the commands below manually:
  1. aws eks update-kubeconfig --region us-east-1 --name roboshop
  2. aws eks describe-cluster --region us-east-1 --name roboshop --query 'cluster.status'
  3. eksctl get nodegroup --cluster roboshop --region us-east-1
  4. kubectl get nodes
======================================================================
EOT
}
