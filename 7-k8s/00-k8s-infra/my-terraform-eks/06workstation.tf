resource "aws_instance" "workstation" {
  ami           = local.ami_id
  instance_type = "t3.micro"

  vpc_security_group_ids = [
    aws_security_group.workstation.id
  ]

  iam_instance_profile = aws_iam_instance_profile.workstation.name

  user_data = templatefile("${path.module}/workstation.sh.tftpl", {})

  root_block_device {
    volume_size = 50
    volume_type = "gp3"

    tags = merge(
      {
        Name = "${var.project}-${var.environment}-workstation"
      },
      local.common_tags
    )
  }

  tags = merge(
    {
      Name = "${var.project}-${var.environment}-workstation"
    },
    local.common_tags
  )
}


resource "aws_security_group" "workstation" {
  name        = "allow-all-workstation"
  description = "Allow SSH inbound and all outbound traffic"

  ingress {
    description = "SSH from my public IP"

    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "${chomp(data.http.my_public_ip.response_body)}/32"
    ]
  }

  egress {
    from_port = 0
    to_port   = 0

    protocol = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]

    ipv6_cidr_blocks = [
      "::/0"
    ]
  }

  tags = merge(
    {
      Name = "${var.project}-${var.environment}-workstation"
    },
    local.common_tags
  )

  lifecycle {
    create_before_destroy = true
  }
}


output "workstation_public_ip" {
  value = aws_instance.workstation.public_ip
}