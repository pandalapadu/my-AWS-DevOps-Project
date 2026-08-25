##Backend_ALB_Security_Group
data "aws_ssm_parameter" "backend_alb_sg_id" {
  name = "/${var.project}/${var.environment}/backend_alb_sg_id"
}

## All Database Subnets IDs will shown
data "aws_ssm_parameter" "private_subnet_ids" {
  name = "/${var.project}/${var.environment}/private_subnet_ids"
}