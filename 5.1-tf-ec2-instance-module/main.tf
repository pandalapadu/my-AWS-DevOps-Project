resource "aws_instance" "terraform_demo" {
  ami                    = local.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = var.sg_ids

  tags = merge(
    var.ec2_tags,
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-${var.component}"
    }
  )
}