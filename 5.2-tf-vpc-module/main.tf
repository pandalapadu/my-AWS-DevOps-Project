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
#Private Subnet
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index] ## us-east-1a
  map_public_ip_on_launch = false
  tags = merge(
    var.private_subnet_tags,
    local.common_tags,
    {
      Name = "${local.common_name}-private-${split("-", local.az_names[count.index]) [2]}"
    }
  )
}
##Database subnet
resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  cidr_block = var.database_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index] ## us-east-1a
  map_public_ip_on_launch = false
  tags = merge(
    var.database_subnet_tags,
    local.common_tags,
    {
      Name = "${local.common_name}-database-${split("-", local.az_names[count.index]) [2]}"
    }
  )
}
#########Route Table resource Creation ##
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    var.public_route_table_tags,
    local.common_tags,
    {
      Name = "${local.common_name}-public"
    }
  )
}
#private
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    var.private_route_table_tags,
    local.common_tags,
    {
      Name = "${local.common_name}-private"
    }
  )
}
#database
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    var.database_route_table_tags,
    local.common_tags,
    {
      Name = "${local.common_name}-database"
    }
  )
}
#########Route Table Subnets Association resource Creation ##
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public
}
#Private
resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)
  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private
}
#Database
resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidrs)
  subnet_id = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database
}