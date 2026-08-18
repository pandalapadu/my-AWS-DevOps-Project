resource "aws_instance" "terraform_demo" {
  count                  = 4
  ami                    = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.allow_terrafom.id] #list
  tags = {
    Name = var.instances[count.index]
  }
}

resource "aws_security_group" "allow_terrafom" {
  name        = var.sg_name
  description = "Security group for Terraform EC2"

  egress {
    from_port   = var.port
    to_port     = var.port
    protocol    = "-1"
    cidr_blocks = var.cidr
  }

  tags = { Name = var.instances[count.index] }
}