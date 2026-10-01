###mongodb_sg_id pulling from parameter store 
data "aws_ssm_parameter" "mongodb_sg_id" {
  name = "/${var.project}/${var.environment}/mongodb_sg_id"
}
###redis_sg_id pulling from parameter store 
data "aws_ssm_parameter" "redis_sg_id" {
  name = "/${var.project}/${var.environment}/redis_sg_id"
}
###mysql_sg_id pulling from parameter store 
data "aws_ssm_parameter" "mysql_sg_id" {
  name = "/${var.project}/${var.environment}/mysql_sg_id"
}
###rabbitmq_sg_id pulling from parameter store 
data "aws_ssm_parameter" "rabbitmq_sg_id" {
  name = "/${var.project}/${var.environment}/rabbitmq_sg_id"
}

###public_alb_sg_id pulling from parameter store 
data "aws_ssm_parameter" "public_alb_sg_id" {
  name = "/${var.project}/${var.environment}/public_alb_sg_id"
}

###bastio ID
data "aws_ssm_parameter" "bastion_sg_id" {
  name = "/${var.project}/${var.environment}/bastion_sg_id"
}

###eks_control_plane_sg_id ID
data "aws_ssm_parameter" "eks_control_plane_sg_id" {
  name = "/${var.project}/${var.environment}/eks_control_plane_sg_id"
}

###eks_node ID
data "aws_ssm_parameter" "eks_node_sg_id" {
  name = "/${var.project}/${var.environment}/eks_node_sg_id"
}

data "aws_ssm_parameter" "jenkins_sg_id" {
    name = "/${var.project}/${var.environment}/jenkins_sg_id"
}

data "aws_ssm_parameter" "jenkins_agent_sg_id" {
    name = "/${var.project}/${var.environment}/jenkins_agent_sg_id"
}
data "aws_ssm_parameter" "sonar_sg_id" {
    name = "/${var.project}/${var.environment}/sonar_sg_id"
}

###############getting my laptop Public IP
data "http" "my_public_ip" {
  url = "https://ipv4.icanhazip.com"
}