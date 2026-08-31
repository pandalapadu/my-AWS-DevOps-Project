
data "aws_ssm_parameter" "frontend_alb_sg_id" {
    name = "/${var.project}/${var.environment}/frontend_alb_sg_id"
}

data "aws_ssm_parameter" "public_subnet_ids" {
    name = "/${var.project}/${var.environment}/public_subnet_ids"
}

data "aws_ssm_parameter" "certificate_arn" {
    name = "/${var.project}/${var.environment}/certificate_arn"
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
