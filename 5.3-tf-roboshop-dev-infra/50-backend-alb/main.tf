resource "aws_lb" "backend_alb" {
  name               = "${local.common_name}-backend_alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [local.backend_alb_sg_id]
  subnets            = [local.private_subnet_ids]

  enable_deletion_protection = false

  tags = merge(
    {
      Name = "${local.common_name}-backend_alb"
    },
    local.common_tags
  )
}