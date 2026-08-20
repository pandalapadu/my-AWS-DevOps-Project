resource "aws_instance" "terraform_demo" {
  ami                    = "ami-0220d79f3f480ecf5"
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.allow_terrafom.id] #list

  tags = {
    Name        = "${var.project}-${var.environment}-tfvars"
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_security_group" "allow_terrafom" {
  name        = "${var.project}-${var.environment}-sg"
  description = "Security group for Terraform EC2"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project}-${local.environment}-SG"
    Project     = var.project
    Environment = var.environment
  }
}