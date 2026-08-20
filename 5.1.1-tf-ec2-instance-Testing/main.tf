module "ec2" {
  source        = "../5.1-tf-ec2-instance-module"
  project       = var.project_name
  environment   = var.env
  component     = var.component_name
  instance_type = var.instance_type
  sg_ids        = var.sg_ids
  ec2_tags      = var.ec2_tags
}