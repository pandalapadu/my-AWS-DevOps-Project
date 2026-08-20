module "ec2" {
  source = "../5.1-tf-ec2-instance-module"
  project = "roboshop"
  environment = "dev"
  component = "Practice"
  sg_ids = ["sg-0953383669051eb35"]
}