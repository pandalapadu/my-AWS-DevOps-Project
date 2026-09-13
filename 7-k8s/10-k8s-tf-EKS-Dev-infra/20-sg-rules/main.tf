#MongoDB Allowing connections from catalogue service on port 27017
resource "aws_security_group_rule" "mongodb_catalogue" {
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  source_security_group_id = local.catalogue_sg_id
  security_group_id        = local.mongodb_sg_id
}
#MongoDB Allowing connections from user service on port 27017
resource "aws_security_group_rule" "mongodb_user" {
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  source_security_group_id = local.user_sg_id
  security_group_id        = local.mongodb_sg_id
}
#MongoDB Allowing connections from bastion on port 22
resource "aws_security_group_rule" "mongodb_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = local.bastion_sg_id
  security_group_id        = local.mongodb_sg_id
}
#redis Allowing connections from user service on port 6379
resource "aws_security_group_rule" "redis_user" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = local.user_sg_id
  security_group_id        = local.redis_sg_id
}
#redis Allowing connections from cart service on port 6379
resource "aws_security_group_rule" "redis_cart" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = local.cart_sg_id
  security_group_id        = local.redis_sg_id
}
#redis Allowing connections from bastion service on port 22
resource "aws_security_group_rule" "redis_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = local.bastion_sg_id
  security_group_id        = local.redis_sg_id
}
#mysql Allowing connections from shipping service on port 3306
resource "aws_security_group_rule" "mysql_shipping" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = local.shipping_sg_id
  security_group_id        = local.mysql_sg_id
}
#mysql Allowing connections from bastion service on port 22
resource "aws_security_group_rule" "mysql_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = local.bastion_sg_id
  security_group_id        = local.mysql_sg_id
}
#rabbitmq Allowing connections from payment service on port 5672
resource "aws_security_group_rule" "rabbitmq_payment" {
  type                     = "ingress"
  from_port                = 5672
  to_port                  = 5672
  protocol                 = "tcp"
  source_security_group_id = local.payment_sg_id
  security_group_id        = local.rabbitmq_sg_id
}
#rabbitmq Allowing connections from bastion service on port 22
resource "aws_security_group_rule" "rabbitmq_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = local.bastion_sg_id
  security_group_id        = local.rabbitmq_sg_id
}
#catalogue Allowing connections from backend_alb service on port 8080
resource "aws_security_group_rule" "catalogue_backend_alb" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = local.backend_alb_sg_id
  security_group_id        = local.catalogue_sg_id
}
#catalogue Allowing connections from bastion service on port 22
resource "aws_security_group_rule" "catalogue_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = local.bastion_sg_id
  security_group_id        = local.catalogue_sg_id
}
# User
#User Allowing connections from backend_alb service on port 8080
resource "aws_security_group_rule" "user_backend_alb" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = local.backend_alb_sg_id
  security_group_id        = local.user_sg_id
}
#User Allowing connections from bastion service on port 22
resource "aws_security_group_rule" "user_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = local.bastion_sg_id
  security_group_id        = local.user_sg_id
}
# Cart
#Cart Allowing connections from backend_alb service on port 8080
resource "aws_security_group_rule" "cart_backend_alb" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = local.backend_alb_sg_id
  security_group_id        = local.cart_sg_id
}
#Cart Allowing connections from bastion service on port 22
resource "aws_security_group_rule" "cart_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = local.bastion_sg_id
  security_group_id        = local.cart_sg_id
}
# Shipping
#Shipping Allowing connections from backend_alb service on port 8080
resource "aws_security_group_rule" "shipping_backend_alb" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = local.backend_alb_sg_id
  security_group_id        = local.shipping_sg_id
}
#Shipping Allowing connections from bastion service on port 22
resource "aws_security_group_rule" "shipping_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = local.bastion_sg_id
  security_group_id        = local.shipping_sg_id
}
# Payment
#Payment Allowing connections from backend_alb service on port 8080
resource "aws_security_group_rule" "payment_backend_alb" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = local.backend_alb_sg_id
  security_group_id        = local.payment_sg_id
}
#Shipping Allowing connections from bastion service on port 22
resource "aws_security_group_rule" "payment_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = local.bastion_sg_id
  security_group_id        = local.payment_sg_id
}
# Backend_ALB
#Backend_ALB Allowing connections from frontend service on port 80
resource "aws_security_group_rule" "backend_alb_frontend" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = local.frontend_sg_id
  security_group_id        = local.backend_alb_sg_id
}
#Backend_ALB Allowing connections from bastion service on port 80 to access backend service 
resource "aws_security_group_rule" "backend_alb_bastion" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = local.bastion_sg_id
  security_group_id        = local.backend_alb_sg_id
}

#Backend_ALB Allowing connections from user service on port 80
resource "aws_security_group_rule" "backend_alb_user" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = local.user_sg_id
  security_group_id        = local.backend_alb_sg_id
}
#Backend_ALB Allowing connections from user service on port 80
resource "aws_security_group_rule" "backend_alb_cart" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = local.cart_sg_id
  security_group_id        = local.backend_alb_sg_id
}
#Backend_ALB Allowing connections from shipping service on port 80
resource "aws_security_group_rule" "backend_alb_shipping" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = local.shipping_sg_id
  security_group_id        = local.backend_alb_sg_id
}
#Backend_ALB Allowing connections from Payment service on port 80
resource "aws_security_group_rule" "backend_alb_payment" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = local.payment_sg_id
  security_group_id        = local.backend_alb_sg_id
}
###############frontend
#Frontend Allowing connections from frontend_alb service on port 80
resource "aws_security_group_rule" "frontend_frontend_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = local.frontend_alb_sg_id
  security_group_id        = local.frontend_sg_id
}
#Frontend Allowing connections from bastion service on port 22
resource "aws_security_group_rule" "frontend_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = local.bastion_sg_id
  security_group_id        = local.frontend_sg_id
}
#Frontend_ALB Allowing connections from Public service on port 44803
resource "aws_security_group_rule" "frontend_alb_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = local.frontend_alb_sg_id
}

#Bastion
resource "aws_security_group_rule" "bastion_my_public_ip" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${trimspace(data.http.my_public_ip.response_body)}/32"]
  security_group_id = local.bastion_sg_id
}