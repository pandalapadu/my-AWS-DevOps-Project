resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = merge(
    var.vpc_tags,
    local.common_tags
  )
}
########IGW resource Creation ##
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    var.igw_tags,
    local.common_tags
  )
}
#### Subnet resource Creation ##
#US-East-1A & US-East-1B
#roboshop-public-1a, roboshop-public-1b
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index] ## us-east-1a
  map_public_ip_on_launch = true
  tags = merge(
    var.public_subnet_tags,
    local.common_tags,
    {
      Name = "${local.common_name}-public-${split("-", local.az_names[count.index]) [2]}"
    }
  )
}
