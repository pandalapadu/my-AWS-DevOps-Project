variable "project" {
  default = "roboshop"
}

variable "instance_type" {
  default = {
    dev  = "t3.micro"
    prod = "t3.small"
  }
}