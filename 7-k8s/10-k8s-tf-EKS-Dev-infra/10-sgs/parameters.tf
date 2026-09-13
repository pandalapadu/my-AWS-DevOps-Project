# Example: Create a plain text SSM parameter
## capturing SG_ID 
resource "aws_ssm_parameter" "sg_id" {
  count       = length(var.sg_names)
  name        = "/${var.project}/${var.environment}/${var.sg_names[count.index]}_sg_id"
  description = " SG_ID "
  type        = "String" # Options: String, StringList, SecureString
  value       = module.sg[count.index].sg_ids
  overwrite   = true
}