locals {
  name          = "${var.project}-${var.environment}"
  instance_type = "t3.micro"
  ami_id        = data.aws_ami.venkat.id
  common_tags = {
    Name        = "${var.project}-${var.environment}"
    Environment = var.environment
    Project     = var.project
  }
  ec2_tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-locals-demo" # roboshop-dev-locals-demo
    }
  )

  sg_tags = merge(
    local.common_tags,
    {
      Name = "${local.name}-common" # roboshop-dev-common
    }
  )
}