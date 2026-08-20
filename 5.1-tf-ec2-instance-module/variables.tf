variable "project" {
  
}

variable "environment" {
  
}

variable "component" {
  
}

variable "instance_type" {
  default = "t3.micro"
    
    validation {
    condition     = contains(["t3.micro", "t3.small" , "t3.medium" ], var.instance_type)
    error_message = "instance_type must be either t3.micro or t3.small or t3.medium."
  }
}

variable "sg_ids" {
  type = list
}

variable "ec2_tags" {
  default = {}
}