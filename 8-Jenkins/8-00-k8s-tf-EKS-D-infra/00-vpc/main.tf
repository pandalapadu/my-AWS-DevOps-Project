module "vpc" {
    source = "git::https://github.com/pandalapadu/my-AWS-DevOps-Project.git//5.2-tf-vpc-module?ref=main"
    project = var.project
    environment = var.environment
}