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
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = local.az_names[count.index] ## us-east-1a
  map_public_ip_on_launch = true
  tags = merge(
    var.public_subnet_tags,
    local.common_tags,
    {
      Name = "${local.common_name}-public-${split("-", local.az_names[count.index])[2]}"
    }
  )
}
#Private Subnet
resource "aws_subnet" "private" {
  count                   = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = local.az_names[count.index] ## us-east-1a
  map_public_ip_on_launch = false
  tags = merge(
    var.private_subnet_tags,
    local.common_tags,
    {
      Name = "${local.common_name}-private-${split("-", local.az_names[count.index])[2]}"
    }
  )
}
##Database subnet
resource "aws_subnet" "database" {
  count                   = length(var.database_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.database_subnet_cidrs[count.index]
  availability_zone       = local.az_names[count.index] ## us-east-1a
  map_public_ip_on_launch = false
  tags = merge(
    var.database_subnet_tags,
    local.common_tags,
    {
      Name = "${local.common_name}-database-${split("-", local.az_names[count.index])[2]}"
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
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
#Private
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
#Database
resource "aws_route_table_association" "database" {
  count          = length(var.database_subnet_cidrs)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}
#######Elastic/Public IP creation for NAT attachement
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = merge(
    var.eip_tags,
    local.common_tags,
    {
      Name = "${local.common_name}-nat"
    }
  )
}
### AWS NAT Gateway Creation ###
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  depends_on    = [aws_internet_gateway.main]
  tags = merge(
    var.nat_gateway_tags,
    local.common_tags
  )
}
### AWS NAT Gateway Route Attached resource Creation ###
##public GateWay_Route
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}
#Private NAT_Gateway_Route
resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}
#Database NAT_Gateway_Route
resource "aws_route" "database" {
  route_table_id         = aws_route_table.database.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}
#### AWS Peering Connection b/w roboshop VPC and default VPC 
##created in sepeare terraform file for this service
#### AWS Peering Connection b/w roboshop VPC and default VPC 
resource "aws_vpc_peering_connection" "default" {
  count       = var.is_peering_required ? 1 : 0
  vpc_id      = aws_vpc.main.id ### Requester VPC
  auto_accept = true
  peer_vpc_id = data.aws_vpc.default.id ### Accepter VPC ID 
  accepter {
    allow_remote_vpc_dns_resolution = true
  }
  requester {
    allow_remote_vpc_dns_resolution = true
  }
  tags = merge(
    var.vpc_peering_tags,
    local.common_tags,
    {
      Name = "${local.common_name}-default-Peering"
    }
  )
}
#### AWS Peering Connection b/w roboshop VPC and default VPC gateway Routes added under Route table
##public GateWay_Route roboshop VPC Side
resource "aws_route" "public_peering" {
  count                     = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
}
##private GateWay_Route roboshop VPC Side
resource "aws_route" "private_peering" {
  count                     = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
}

##Database GateWay_Route roboshop VPC Side
resource "aws_route" "database_peering" {
  count                     = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
}

##Default Gateway Route 
resource "aws_route" "default" {
  count                     = var.is_peering_required ? 1 : 0
  route_table_id            = data.aws_route_table.default.id
  destination_cidr_block    = var.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
}