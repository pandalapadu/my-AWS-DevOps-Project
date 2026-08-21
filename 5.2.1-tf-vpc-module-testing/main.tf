module "vpc" {
  source              = "../5.2-tf-vpc-module"
  project             = var.project
  environment         = var.environment
  is_peering_required = true
}