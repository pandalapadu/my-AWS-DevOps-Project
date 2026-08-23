locals {
  bastion_sg_id    = data.aws_ssm_parameter.bastion_sg_id.value
  ami_id           = data.aws_ami.venkat.id
  public_subnet_id = split(",", data.aws_ssm_parameter.public_sunet_ids.value)[0]
  common_name      = "${var.project}-${var.environment}"
  common_tags = {
    Project     = "${var.project}"
    Environment = "${var.environment}"
    Terraform   = "true"
  }
}