locals {
    ami_id =  data.aws_ami.venkat.id
    common_tags = {
        Project = var.project
        Environment = var.environment
        Terraform = "true"
    }
    
    public_subnet_id = split(",", data.aws_ssm_parameter.public_subnet_ids.value)[0]
    jenkins_sg_id = data.aws_ssm_parameter.jenkins_sg_id.value
    jenkins_agent_sg_id = data.aws_ssm_parameter.jenkins_agent_sg_id.value
    sonar_sg_id = data.aws_ssm_parameter.sonar_sg_id.value
}