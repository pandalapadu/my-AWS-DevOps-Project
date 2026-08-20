locals {
  ami_id = data.aws_ami.venkat.id
  common_tags = {
    Project = var.project
    Environment = var.environment
    Component = var.component
  }
}