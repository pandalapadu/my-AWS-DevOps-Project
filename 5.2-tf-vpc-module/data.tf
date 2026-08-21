data "aws_availability_zones" "available" {
  state = "available"
}
## Default vpc ID
data "aws_vpc" "default" {
  default = true
}
###default VPC Route table 
data "aws_route_table" "default" {
  route_table_id = data.aws_vpc.default.main_route_table_id
}