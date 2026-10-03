variable "project" {
    default = "roboshop"
}

variable "environment" {
    default = "dev"
}

variable "zone_id" {
    default = "Z0580926234LLG39XOC6H"
}

variable "domain_name" {
    default = "azdevopsvenkat.site"
}

variable "sonar" {
    default = false
}

variable "jenkins" {
    default = false
}
variable "jenkins_agent" {
  default = false
}
variable "runner" {
    default = true
}