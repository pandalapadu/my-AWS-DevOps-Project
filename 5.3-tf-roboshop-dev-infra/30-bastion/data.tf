data "aws_ssm_parameter" "bastion_sg_id" {
  name = "/${var.project}/${var.environment}/bastion_sg_id"
}
## Subnet ID 
data "aws_ssm_parameter" "public_sunet_ids" {
  name = "/${var.project}/${var.environment}/public_sunet_ids"
}
## AMI ID 
data "aws_ami" "venkat" {
  most_recent = true
  owners      = ["973714476881"] # Official Red Hat AWS Account ID

  filter {
    name   = "name"
    values = ["Redhat-9-DevOps-Practice"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

output "ami_id" {
  value = data.aws_ami.venkat.id
}