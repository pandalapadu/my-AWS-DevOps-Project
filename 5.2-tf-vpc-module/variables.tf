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
#######IGW Specific #
variable "igw_tags" {
  type = map(any)
  default = {}
}
#######Subnets ######
variable "public_subnet_cidrs" {
  type = list
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}
variable "public_subnet_tags" {
  type = map
  default = {}
}
variable "private_subnet_cidrs" {
  type = list
  default = ["10.0.11.0/24", "10.0.12.0/24"]
}
variable "private_subnet_tags" {
  type = map
  default = {}
}
variable "database_subnet_cidrs" {
  type = list
  default = ["10.0.21.0/24", "10.0.22.0/24"]
}
variable "database_subnet_tags" {
  type = map
  default = {}
}
########Route table
variable "public_route_table_tags" {
  type = map
  default = {}
}
variable "private_route_table_tags" {
  type = map
  default = {}
}
variable "database_route_table_tags" {
  type = map
  default = {}
}