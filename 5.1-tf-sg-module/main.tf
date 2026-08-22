# Create a Security Group
resource "aws_security_group" "main" {
  name        = local.common_name
  description = "Allow traffic for ${var.sg_name} project ${var.project} in ${var.environment}"
  vpc_id      = var.vpc_id 
  # Outbound rules
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"   # -1 means all protocols
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags =  merge(
    var.sg_tags,
    local.common_tags
  )
}