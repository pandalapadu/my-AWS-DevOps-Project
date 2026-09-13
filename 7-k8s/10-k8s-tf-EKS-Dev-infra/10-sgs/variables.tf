variable "project" {
  default = "roboshop"
}
variable "environment" {
  default = "dev"
}
variable "sg_names" {
  type = list(any)
  default = [
  "mongodb", "redis", "mysql", "rabbitmq", 
  #"catalogue", "user", "cart", "shipping","payment", "backend_alb", "frontend", 
  "public_alb", "bastion",
  "eks_control_plane",
  "eks_node"
  ]
}