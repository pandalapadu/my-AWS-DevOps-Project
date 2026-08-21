##########Project Specific##########
variable "project" {
  type = string
}
variable "environment" {
  type = string
}
#######Instance Specific ########
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
variable "vpc_tags" {
  type    = map(any)
  default = {}
}