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
    eks_cluster_name = data.aws_ssm_parameter.eks_cluster_name.value
    eks_cluster_arn = "arn:aws:eks:us-east-1:${data.aws_caller_identity.current.account_id}:cluster/${local.eks_cluster_name}"
}