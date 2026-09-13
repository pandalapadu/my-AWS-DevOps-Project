resource "aws_eks_access_entry" "bastion" {
  cluster_name      = local.eks_cluster_name
  principal_arn     = local.bastion_iam_role_arn
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "bastion" {
  cluster_name  = local.eks_cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = local.bastion_iam_role_arn

  access_scope {
    type       = "cluster"
  }
}

resource "aws_eks_access_entry" "runner" {
  cluster_name      = local.eks_cluster_name
  principal_arn     = local.runner_iam_role_arn
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "runner" {
  cluster_name  = local.eks_cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  principal_arn = local.runner_iam_role_arn

  access_scope {
    type       = "namespace"
    namespaces = ["roboshop-dev", "roboshop-sit", "roboshop-uat", "roboshop-prod"]
  }
}