##MongoDB_Security_Group
data "aws_ssm_parameter" "mongodb_sg_id" {
  name = "/${var.project}/${var.environment}/mongodb_sg_id"
}
##redis_Security_Group
data "aws_ssm_parameter" "redis_sg_id" {
  name = "/${var.project}/${var.environment}/redis_sg_id"
}
# ##rabbitmq_Security_Group
# data "aws_ssm_parameter" "rabbitmq_sg_id" {
#   name = "/${var.project}/${var.environment}/rabbitmq_sg_id"
# }
# ##mySQL_Security_Group
# data "aws_ssm_parameter" "mysql_sg_id" {
#   name = "/${var.project}/${var.environment}/mysql_sg_id"
# }

## All Database Subnets IDs will shown
data "aws_ssm_parameter" "database_subnet_ids" {
  name = "/${var.project}/${var.environment}/database_subnet_ids"
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