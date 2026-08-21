locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    Terraform   = True
    Name        = local.common_name
  }
  common_name = "${var.project}-${var.environment}" #roboshop-dev
}