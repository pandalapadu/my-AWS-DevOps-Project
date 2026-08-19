resource "aws_instance" "terraform_demo" {
  ami                    = "ami-0220d79f3f480ecf5"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.allow_terrafom.id] #list

  tags = {
    Name        = "terraform-demo"
    Project     = "roboshop"
    Environment = "dev"
  }
}

resource "aws_security_group" "allow_terrafom" {
  name        = "Allow-terraform"
  description = "Security group for Terraform EC2"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  tags = {
    Name        = "terraform-SG"
    Project     = "roboshop"
    Environment = "dev"
  }
}