resource "aws_instance" "terraform_demo" {
  ami = data.aws_ami.venkat.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.allow_docker.id] 
   # labels, metadata, info, etc
    user_data = templatefile("${path.module}/docker.sh.tftpl", {
        partition_number = 4
        extend_size = 30
    })
    root_block_device {
        volume_size           = 50      # Size of the volume in GiB
        volume_type           = "gp3"   # General Purpose SSD (gp3 is recommended)
        tags = {
            Name = "docker"
            Project = "roboshop"
            Environment = "dev"
        }
    }

    tags = {
        Name = "docker"
        Project = "roboshop"
        Environment = "dev"
    }
}