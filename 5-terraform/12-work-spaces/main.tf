resource "aws_instance" "terraform_demo" {
  ami                    = "ami-0220d79f3f480ecf5"
  instance_type          = lookup(var.instance_type, local.environment)
  vpc_security_group_ids = [aws_security_group.allow_terrafom.id] #list

  tags = {
    Name        = "${var.project}-${local.environment}-workspace"
    Project     = var.project
    Environment = local.environment
  }
}

resource "aws_security_group" "allow_terrafom" {
  name        = "${var.project}-${local.environment}-sg"
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
    Environment = local.environment
  }
}