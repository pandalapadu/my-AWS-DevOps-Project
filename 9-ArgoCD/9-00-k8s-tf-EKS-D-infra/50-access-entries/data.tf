data "aws_ssm_parameter" "eks_cluster_name" {
    name = "/${var.project}/${var.environment}/eks_cluster_name"
} 

data "aws_ssm_parameter" "bastion_iam_role_arn" {
  name = "/${var.project}/${var.environment}/bastion_iam_role_arn"
}

# data "aws_ssm_parameter" "runner_iam_role_arn" {
#   name = "/${var.project}/${var.environment}/runner_iam_role_arn"
# }