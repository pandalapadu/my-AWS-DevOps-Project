locals{
    eks_cluster_name = "roboshop"
    #data.aws_ssm_parameter.eks_cluster_name.value
    bastion_iam_role_arn = data.aws_ssm_parameter.bastion_iam_role_arn.value
    runner_iam_role_arn = data.aws_ssm_parameter.runner_iam_role_arn.value
}