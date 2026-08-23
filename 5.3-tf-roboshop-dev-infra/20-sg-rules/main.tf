#MongoDB Allowing connections from catalogue service
resource "aws_security_group_rule" "name" {
  type = "ingress"
  from_port = 27017
  to_port = 27017
  protocol = "tcp"
  source_security_group_id = 
  security_group_id = 
}