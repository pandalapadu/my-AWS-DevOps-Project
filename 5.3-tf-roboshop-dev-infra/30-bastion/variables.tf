provider "aws" {
  region = "us-east-1"
}

variable "project" {
  default = "roboshop"
}
variable "environment" {
  default = "dev"
}
