# Example: Create a plain text SSM parameter
## capturing SG_IDs 
# resource "aws_ssm_parameter" "sg_id" {
#   name        = "/${var.project}/${var.environment}/vpc_id"
#   description = " VPC_ID "
#   type        = "String" # Options: String, StringList, SecureString
#   value       = module.vpc.vpc_id
#   overwrite   = true
# }