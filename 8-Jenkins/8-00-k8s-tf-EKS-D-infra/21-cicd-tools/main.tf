resource "aws_instance" "jenkins" {
  count = var.jenkins ? 1 : 0

  ami           = local.ami_id
  instance_type = "t3.small"

  subnet_id              = local.public_subnet_id
  vpc_security_group_ids = [local.jenkins_sg_id]

  user_data = file("${path.module}/jenkins.sh")

  root_block_device {
    volume_size = 50
    volume_type = "gp3"

    tags = merge(
      local.common_tags,
      {
        Name = "${var.project}-${var.environment}-jenkins"
      }
    )
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-jenkins"
    }
  )
}

resource "aws_instance" "jenkins_agent" {
  count = var.jenkins_agent ? 1 : 0

  ami           = local.ami_id
  instance_type = "t3.micro"

  subnet_id              = local.public_subnet_id
  vpc_security_group_ids = [local.jenkins_agent_sg_id]

  user_data = file("${path.module}/jenkins-agent.sh")

  root_block_device {
    volume_size = 50
    volume_type = "gp3"

    tags = merge(
      local.common_tags,
      {
        Name = "${var.project}-${var.environment}-jenkins-agent"
      }
    )
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-jenkins-agent"
    }
  )
}

resource "aws_instance" "sonarqube" {
  count = var.sonar ? 1 : 0

  ami           = local.ami_id
  instance_type = "t3.medium"

  subnet_id              = local.public_subnet_id
  vpc_security_group_ids = [local.sonar_sg_id]
  user_data = file("${path.module}/sonar.sh")

  root_block_device {
    volume_size = 50
    volume_type = "gp3"

    tags = merge(
      local.common_tags,
      {
        Name = "${var.project}-${var.environment}-sonar"
      }
    )
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-sonar"
    }
  )
}