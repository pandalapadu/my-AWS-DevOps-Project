resource "aws_iam_role" "workstation" {
  name = "${var.project}-${var.environment}-workstation-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}


resource "aws_iam_instance_profile" "workstation" {
  name = "${var.project}-${var.environment}-workstation-profile"

  role = aws_iam_role.workstation.name
}
resource "aws_iam_role_policy_attachment" "workstation_admin" {
  role = aws_iam_role.workstation.name

  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}