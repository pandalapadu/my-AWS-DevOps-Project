resource "aws_iam_role" "bastion" {
 name = "${local.common_name}-bastion"
 #Terraform jsonencode() function converts a tf results in to valid JSON syntax.
 assume_role_policy = jsonencode({
   Version = "2012-10-17"
   Statement = [
     {
       Action = "sts:AssumeRole"
       Effect = "Allow"
       Sid = ""
       Principal = {
         Service = "ec2.amazonaws.com"
       }
      
     }
   ]
 })
 tags = merge(
    local.common_tags,
    {
        Name = "${local.common_name}-bastion"
    }
 )
}
# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "bastion" {
role = aws_iam_role.bastion.name
policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
# Create an IAM Instance Profile
resource "aws_iam_instance_profile" "bastion" {
  name = "${local.common_name}-bastion"
  role = aws_iam_role.bastion.name
}