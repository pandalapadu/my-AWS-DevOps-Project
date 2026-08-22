module "sg" {
  source = "git::https://github.com/pandalapadu/my-AWS-DevOps-Project.git//5.1-tf-sg-module?ref=main"
  project = var.project
  environment = var.environment
  vpc_id = local.vpc_id
  sg_name = "mongodb"
}