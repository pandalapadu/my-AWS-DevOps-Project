resource "aws_instance" "terraform_demo" {
  ami                    = data.aws_ami.venkat.id
  instance_type          = "${local.instance_type}"
  vpc_security_group_ids = [aws_security_group.allow_terrafom.id] #list
  tags = {
    Name = local.name
  }

}

resource "aws_security_group" "allow_terrafom" {
  name        = "${local.name}-common"
  description = "Security group for Terraform EC2"

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.name
}