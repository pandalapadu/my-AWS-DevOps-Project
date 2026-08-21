resource "aws_vpc" "name" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = marge(
    var.vpc_tags,
    local.common_tags
  )

}