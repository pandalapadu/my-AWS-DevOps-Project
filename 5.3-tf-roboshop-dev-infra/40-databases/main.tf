resource "aws_instance" "mongodb" {
  ami                    = local.ami_id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [local.mongodb_sg_id]
  subnet_id              = local.database_subnet_id
  user_data = templatefile("${path.module}/bastion.sh.tftpl", {
    partition_number = 4
    extend_size = 30
  })
  tags = merge(
    local.common_tags,
    {
      Name = "${local.common_name}-mongodb"
    }

  )
}