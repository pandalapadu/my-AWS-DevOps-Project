# Example: Create a plain text SSM parameter
## capturing VPC_ID 
resource "aws_ssm_parameter" "vpc_id" {
  name        = "/${var.project}/${var.environment}/vpc_id"
  description = " VPC_ID "
  type        = "String" # Options: String, StringList, SecureString
  value       = module.vpc.vpc_id
  overwrite   = true
}
## capturing Public subnet ID 
resource "aws_ssm_parameter" "public_subnet_ids" {
  name        = "/${var.project}/${var.environment}/public_subnet_ids"
  description = " public_subnet_ids "
  type        = "String" # Options: String, StringList, SecureString
  value       = join("," , module.vpc.public_subnet_ids)
  overwrite   = true
}
## capturing private subnet ID 
resource "aws_ssm_parameter" "private_subnet_ids" {
  name        = "/${var.project}/${var.environment}/private_subnet_ids"
  description = " private_subnet_ids "
  type        = "String" # Options: String, StringList, SecureString
  value       = join("," , module.vpc.private_subnet_ids)
  overwrite   = true
}

## capturing Database subnet ID 
resource "aws_ssm_parameter" "database_subnet_ids" {
  name        = "/${var.project}/${var.environment}/database_subnet_ids"
  description = " database_subnet_ids "
  type        = "String" # Options: String, StringList, SecureString
  value       = join("," , module.vpc.database_subnet_ids)
  overwrite   = true
}