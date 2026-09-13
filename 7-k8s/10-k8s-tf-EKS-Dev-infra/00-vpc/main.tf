module "vpc" {
    source = "git::https://github.com/pandalapadu/my-AWS-DevOps-Project.git//5.1-tf-ec2-instance-module?ref=main"
    project = var.project
    environment = var.environment
    is_peering_required = false
}