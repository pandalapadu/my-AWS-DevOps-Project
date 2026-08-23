#MongoDB Allowing connections from catalogue service on port 27017
resource "aws_security_group_rule" "mongodb_catalogue" {
  type = "ingress"
  from_port = 27017
  to_port = 27017
  protocol = "tcp"
  source_security_group_id = local.catalogue_sg_id
  security_group_id = local.mongodb_sg_id
}
#MongoDB Allowing connections from user service on port 27017
resource "aws_security_group_rule" "mongodb_user" {
  type = "ingress"
  from_port = 27017
  to_port = 27017
  protocol = "tcp"
  source_security_group_id = local.user_sg_id
  security_group_id = local.mongodb_sg_id
}
#MongoDB Allowing connections from bastion on port 22
resource "aws_security_group_rule" "mongodb_bastion" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = local.bastion_sg_id
  security_group_id = local.mongodb_sg_id
}