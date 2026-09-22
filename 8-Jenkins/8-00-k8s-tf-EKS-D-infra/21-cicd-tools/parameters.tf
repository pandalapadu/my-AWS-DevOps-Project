resource "aws_ssm_parameter" "runner_iam_role_arn" {
  count     = var.runner ? 1 : 0
  name      = "/${var.project}/${var.environment}/runner_iam_role_arn"
  type      = "String"
  value     = aws_iam_role.runner[0].arn
  overwrite = true
}