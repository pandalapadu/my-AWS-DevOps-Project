resource "aws_instance" "bastion" {
  ami                    = local.ami_id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [local.bastion_sg_id]
  subnet_id              = local.public_subnet_id
  # Configuring the root block device
  root_block_device {
    volume_type           = "gp3" # General Purpose SSD (gp2/gp3) or io1/io2
    volume_size           = 50    # Size in GB
    delete_on_termination = true  # Delete volume when instance is terminated
    tags = merge(
      local.common_tags,
      {
        Name = "${local.common_name}-volume"
      }

    )
  }
  tags = merge(
    local.common_tags,
    {
      Name = "${local.common_name}-bastion"
    }

  )
}