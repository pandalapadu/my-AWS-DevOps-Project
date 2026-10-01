resource "aws_ssm_parameter" "eks_cluster_name" {
  name      = "/${var.project}/${var.environment}/eks_cluster_name"
  type      = "String"
  value     = module.eks.cluster_name
  overwrite = true
}