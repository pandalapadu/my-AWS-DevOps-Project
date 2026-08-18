resource "aws_instance" "terraform_demo" {
  count                  = 4
  ami                    = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.allow_terrafom[count.index].id] #list
  tags = {
    Name = "${var.project}-${var.environment}-${var.instances[count.index]}" #interpolation
  }
}

resource "aws_security_group" "allow_terrafom" {
  count       = 4
  name        = "${var.project}-${var.environment}-${var.instances[count.index]}" #interpolation
  description = "Security group for Terraform EC2"

  egress {
    from_port   = var.port
    to_port     = var.port
    protocol    = "-1"
    cidr_blocks = var.cidr
  }

  tags = {
    Name = "${var.project}-${var.environment}-${var.instances[count.index]}" #interpolation
  }
}