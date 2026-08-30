resource "aws_acm_certificate" "roboshop" {
  domain_name = "*.${var.domain_name}"
  validation_method = "DNS"
  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}"
    }
  )
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "name" {
  
}