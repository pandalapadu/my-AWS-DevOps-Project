variable "project" {
  default = "roboshop"
}

variable "environment" {
  default = "dev"
}
variable "is_peering_required" {
  type = bool
  default = false
}