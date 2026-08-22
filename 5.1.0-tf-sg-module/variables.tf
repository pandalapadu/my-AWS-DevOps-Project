# Create a Security Group
resource "aws_security_group" "example" {
  name        = "example-security-group"
  description = "Security group for example purposes"
  vpc_id      = "vpc-12345678" # replace with your VPC ID

  # Inbound rules
  ingress {
    description      = "Allow SSH from anywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Allow HTTP from anywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  # Outbound rules
  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"   # -1 means all protocols
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "example-security-group"
  }
}

# Output the Security Group ID
output "security_group_id" {
  value = aws_security_group.example.id
}