resource "aws_instance" "terraform_demo" {
  ami                    = "ami-0220d79f3f480ecf5"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.allow_terrafom.id] #list

  tags = {
    Name        = "terraform-demo"
    Project     = "roboshop"
    Environment = "dev"
  }
  provisioner "local-exec" {
    command = "echo instance created ${self.private_ip} > inventory.ini"
  }
  provisioner "local-exec" {
    command = "echo instance created "
  }
  provisioner "local-exec" {
    when    = destroy
    command = "echo instance going to be destroyed "
  }
  provisioner "local-exec" {
    when    = destroy
    command = "echo > inventory.ini "
  }
  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = self.public_ip
  }
  # provisioner "remote-exec" {
  #   inline = [
  #     "sudo dnf install nginx -y",
  #     "sudo systemctl start nginx"
  #   ]
  # }
  #   provisioner "remote-exec" {
  #     when = destroy
  #   inline = [
  #     "sudo systemctl stop nginx"
  #   ]
  # }
  provisioner "file" {
    source = "script.sh"
    destination = "/tmp/script.sh"
  }
}

resource "aws_security_group" "allow_terrafom" {
  name        = "Allow-terraform-provisioners"
  description = "Security group for Terraform EC2"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "terraform-SG"
    Project     = "roboshop"
    Environment = "dev"
  }
}