module "ec2" {
  source = "../5.1-tf-ec2-instance-module"
  project = var.project_name
  environment = var.env
  component = var.component_name
  instance_type = var.instance_type
  sg_ids = ["sg-0953383669051eb35"]
}