module "vpc" {
  #source              = "../5.2-tf-vpc-module"
  source              = "git::https://github.com/pandalapadu/my-AWS-DevOps-Project.git//5.2.1-tf-vpc-module-testing?ref=main"
  project             = var.project
  environment         = var.environment
  is_peering_required = "true"
}