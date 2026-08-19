variable "ami_id" {
  type        = string
  default     = "ami-0220d79f3f480ecf5"
  description = "RHEL-9 Customized OS image"
}

variable "environment" {
  default = "dev"
}
variable "project" {
  default = "roboshop"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"

  validation {
    condition     = contains(["t3.micro", "t3.small", "t3.medium", "t3.large"], var.instance_type)
    error_message = "instance_type must be either t3.micro or t3.small or t3.medium."
  }
}

variable "ec2_tags" {
  type = map(any)
  default = {
    Name        = "terraform-demo"
    Project     = "roboshop"
    Environment = "dev"
  }
}

variable "sg_name" {
  default = "allow_terraform"
}

variable "port" {
  default = 0
}

variable "cidr" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "instances" {
  type = map(any)
  default = {
    mongodb   = { "instance_type" = "t3.micro" },
    redis     = { "instance_type" = "t3.small" },
    rabbitmq  = { "instance_type" = "t3.medium" },
    mysql     = { "instance_type" = "t3.medium" },
    catalogue = { "instance_type" = "t3.medium" },
    user      = { "instance_type" = "t3.medium" },
    cart      = { "instance_type" = "t3.medium" },
    shipping  = { "instance_type" = "t3.medium" },
    payment   = { "instance_type" = "t3.medium" },
    frontend  = { "instance_type" = "t3.medium" }
  }
  #["mongodb", "redis", "rabbitmq", "mysql", "catalogue", "user", "cart", "shipping", "payment", "frontend"]
}
#########Route 53 Records Variables ###
variable "zone_id" {
  default = "Z0580926234LLG39XOC6H"
}
variable "domain_name" {
  default = "azdevopsvenkat.site"
}