resource "aws_instance" "terraform_demo" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.allow_terrafom.id] #list

  tags = merge(
    var.common_tags,
    {
      Name      = "terraform-demo"
      Component = "Demo"
    }
  )
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

  tags = merge(
    var.common_tags,
    {
      Name      = var.sg_name
      Component = "Demo"
    }
  )
}