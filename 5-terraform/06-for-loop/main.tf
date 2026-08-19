resource "aws_instance" "roboshop" {
  for_each      = var.instances
  ami           = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [
    aws_security_group.roboshop[each.key].id,
    aws_security_group.common.id
  ] #list
  tags = {
    Name = "${var.project}-${var.environment}-${each.key}" #interpolation
  }
}

resource "aws_security_group" "roboshop" {
  for_each    = var.instances
  name        = "${var.project}-${var.environment}-${each.key}" #interpolation
  description = "Security group for Terraform EC2"

  egress {
    from_port   = var.port
    to_port     = var.port
    protocol    = "-1"
    cidr_blocks = var.cidr
  }

  tags = {
    Name = "${var.project}-${var.environment}-${each.key}" #interpolation
  }
  ## first it create SG and modify instance SG
  lifecycle {
    create_before_destroy = true
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
  ## first it create SG and modify instance SG
  lifecycle {
    create_before_destroy = true
  }
}