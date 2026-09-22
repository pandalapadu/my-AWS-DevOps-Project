resource "aws_lb" "public_alb" {
  name               = "${local.common_name}-frontend-alb" # roboshop-dev-frontend-alb
  internal           = false
  load_balancer_type = "application"
  security_groups    = [local.public_alb_sg_id]
  subnets            = local.public_subnet_ids

  enable_deletion_protection = false # usuaully true, but while practicing make it false

  tags = merge(
    {
        Name = "${local.common_name}-frontend-alb"
    },
    local.common_tags
  )
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.public_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = local.certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>Hi, I am from HTTPS Frontend ALB</h1>"
      status_code  = "200"
    }
  }
}

resource "aws_route53_record" "www" {
  zone_id = var.zone_id
  name    = "*.azdevopsvenkat.site" # 
  type    = "A"

  alias {
    # AWS details
    name                   = aws_lb.public_alb.dns_name
    zone_id                = aws_lb.public_alb.zone_id
    evaluate_target_health = true
  }
  allow_overwrite = true
}

/* resource "aws_lb_target_group" "frontend" {
  name     = "${local.common_name}-frontend"
  port     = 80
  protocol = "HTTP"
  vpc_id   = local.vpc_id
  deregistration_delay = 30
  target_type = "ip"

  health_check {
    healthy_threshold = 2
    interval = 10
    matcher = "200-299"
    path = "/"
    port = 80
    protocol = "HTTP"
    timeout = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "frontend" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }

  condition {
    host_header {
      values = ["app1-${var.environment}.${var.domain_name}"] # app1-dev.daws90s.shop
    }
  }
}*/

resource "aws_lb_target_group" "app2" {
  name     = "${local.common_name}-app2"
  port     = 80
  protocol = "HTTP"
  vpc_id   = local.vpc_id
  deregistration_delay = 30
  target_type = "ip"

  health_check {
    healthy_threshold = 2
    interval = 10
    matcher = "200-299"
    path = "/"
    port = 80
    protocol = "HTTP"
    timeout = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "app2" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app2.arn
  }

  condition {
    host_header {
      values = ["app2-${var.environment}.${var.domain_name}"] # app2-dev.daws90s.shop
    }
  }
} 

resource "aws_lb_target_group" "frontend" {
  name     = "${local.common_name}-frontend"
  port     = 80
  protocol = "HTTP"
  vpc_id   = local.vpc_id
  deregistration_delay = 30
  target_type = "ip"

  health_check {
    healthy_threshold = 2
    interval = 10
    matcher = "200-299"
    path = "/"
    port = 80
    protocol = "HTTP"
    timeout = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "frontend" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }

  condition {
    host_header {
      values = ["dev.${var.domain_name}"] # app1-dev.daws90s.shop
    }
  }
}