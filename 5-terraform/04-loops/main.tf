resource "aws_instance" "roboshop" {
  count         = 4
  ami           = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [
    aws_security_group.roboshop [count.index].id,
    aws_security_group.common.id
  ] #list
  tags = {
    Name = "${var.project}-${var.environment}-${var.instances[count.index]}" #interpolation
  }
}

resource "aws_security_group" "roboshop" {
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

resource "aws_security_group" "common" {
  name        = "${var.project}-${var.environment}-common" #interpolation
  description = "Security group for Terraform EC2"

  egress {
    from_port   = var.port
    to_port     = var.port
    protocol    = "-1"
    cidr_blocks = var.cidr
  }

  tags = {
    Name = "${var.project}-${var.environment}-common" #interpolation
  }
}