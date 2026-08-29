resource "aws_lb" "backend_alb" {
  name               = "${local.common_name}-backend_alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [local.backend_alb_sg_id]
  subnets            = local.private_subnet_ids

  enable_deletion_protection = false

  tags = merge(
    {
      Name = "${local.common_name}-backend_alb"
    },
    local.common_tags
  )
}
#### Listner creation 
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.backend_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>Hi, i am From Backend ALB from terrafom</h1><p>We will be back online shortly.</p>"
      status_code  = "200"
    }
  }
}

# Create the Alias Record pointing to the ALB
resource "aws_route53_record" "www" {
  zone_id = var.zone_id # Your Route 53 Hosted Zone ID
  name    = "*.backend-alb-${var.environment}-azdevopsvenkat.site"
  type    = "A"

  alias {
    name                   = aws_lb.backend_alb.dns_name     # Dynamically references ALB DNS name
    zone_id                = aws_lb.backend_alb.zone_id     # Dynamically references ALB Canonical Zone ID
    evaluate_target_health = true
  }
}
