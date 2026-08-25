### ALB resource creation
resource "aws_lb" "backend_alb" {
  name = "${local.common_name}-backend-alb"
  internal = true
  load_balancer_type = "application"
  security_groups = [local.backend_alb_sg_id]
  subnets = local.private_subnet_ids
  enable_deletion_protection = true
  tags = merge(
    {
        Name = "${local.common_name}-backend-alb"
    },
    local.common_tags
  )
}

#ALB_Lisitner creation
resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.backend_alb.arn
  port = "80"
  protocol = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/html"
      message_body = "<h1>Hi, HTTP backend ALB Configuration </h1>"
      status_code = "200"
    }
  }
}
####AWS Route53 record creation for ALB access
resource "aws_route53_record" "www" {
  zone_id = var.zone_id
  name = "*.backend-alb-${var.environment}.{var.domain_name}"
  type = "A"
  allow_overwrite = true
  alias {
    name = aws_lb.backend_alb.dns_name
    zone_id = aws_lb.backend_alb.zone_id
    evaluate_target_health = true
  }
}