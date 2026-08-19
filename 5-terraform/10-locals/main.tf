resource "aws_instance" "terraform_demo" {
  ami                    = local.ami_id
  instance_type          = local.instance_type
  vpc_security_group_ids = [aws_security_group.allow_terrafom.id] #list
  tags = local.ec2_tags

}

resource "aws_security_group" "allow_terrafom" {
  name        = "${local.name}-common"
  description = "Security group for Terraform EC2"

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.sg_tags
}