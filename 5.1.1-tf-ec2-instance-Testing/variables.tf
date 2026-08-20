variable "project_name" {
  default = "roboshop"
}

variable "env" {
  default = "dev"
}

variable "component_name" {
  default = "Testing"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "sg_ids" {
  default = ["sg-0953383669051eb35"]
}

variable "ec2_tags" {
  default = {
    Purpose = "module-demo"
  }
}