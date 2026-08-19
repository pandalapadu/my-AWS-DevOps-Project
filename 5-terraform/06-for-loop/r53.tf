# Create the A record
resource "aws_route53_record" "roboshop" {
  for_each = aws_instance.roboshop
  zone_id  = var.zone_id
  name     = "${each.key}-${var.environment}.${var.domain_name}" ##mongodb-dev.azdevopsvenkat.site
  type     = "A"
  ttl      = 1
  records  = [each.value.private_ip] # getting Private IP
}

# Create the A record
resource "aws_route53_record" "frontend" {
  for_each = contains(keys(var.instances), "frontend") ? 1 : 0
  zone_id  = var.zone_id
  name     = "${var.project}-${var.environment}.${var.domain_name}" ##roboshop-dev.azdevopsvenkat.site
  type     = "A"
  ttl      = 1
  records  = [lookup(aws_instance.roboshop, "frontend").public_ip] # getting Private IP
}