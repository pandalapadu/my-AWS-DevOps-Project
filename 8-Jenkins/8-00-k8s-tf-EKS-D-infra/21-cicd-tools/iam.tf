resource "aws_iam_role" "runner" {
  count = var.runner ? 1 : 0
  name  = "${var.project}-${var.environment}-runner"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-runner"
    }
  )
}

# This will give runner ECR push and pull access
resource "aws_iam_role_policy_attachment" "runner_ecr" {
  count      = var.runner ? 1 : 0
  role       = aws_iam_role.runner[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_policy" "runner_eks_describe" {
  count = var.runner ? 1 : 0
  name  = "${var.project}-${var.environment}-runner-eks-describe"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["eks:DescribeCluster"]
        Effect   = "Allow"
        Resource = local.eks_cluster_arn
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "runner_eks_describe" {
  count      = var.runner ? 1 : 0
  role       = aws_iam_role.runner[0].name
  policy_arn = aws_iam_policy.runner_eks_describe[0].arn
}

resource "aws_iam_instance_profile" "runner" {
  count = var.runner ? 1 : 0
  name  = "${var.project}-${var.environment}-runner"
  role  = aws_iam_role.runner[0].name
}