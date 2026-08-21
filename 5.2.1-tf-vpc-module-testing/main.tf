module "vpc" {
  source      = "../5.2-tf-vpc-module"
  project     = "roboshop"
  environment = "Dev"
}