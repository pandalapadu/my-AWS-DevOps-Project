resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.venkat.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [local.bastion_sg_id]
  subnet_id              = local.public_subnet_id
  iam_instance_profile   = aws_iam_instance_profile.bastion.name
  user_data = templatefile("${path.module}/bastion.sh.tftpl", {
    partition_number = 4
    extend_size      = 30
  })
  root_block_device {
    volume_size = 50    # Size of the volume in GiB
    volume_type = "gp3" # General Purpose SSD (gp3 is recommended)

    tags = merge(
      {
        Name = "${local.common_name}-bastion"
      },
      local.common_tags
    )
  }

  tags = merge(
    {
      Name = "${local.common_name}-bastion"
    },
    local.common_tags
  )
}

output "workstation_public_ip" {
  value = aws_instance.workstation.public_ip
}
##########
# Resource to execute the validation commands sequentially after cluster infrastructure is ready
output "deployment_complete" {
  value = <<-EOT
======================================================================
                    CLUSTER DEPLOYMENT COMPLETE
======================================================================

Your cluster context has been updated automatically.

If your nodes are still initializing, run:

  1. aws eks update-kubeconfig --region us-east-1 --name roboshop
  2. aws eks describe-cluster --region us-east-1 --name roboshop --query 'cluster.status'
  3. eksctl get nodegroup --cluster roboshop --region us-east-1
  4. kubectl get nodes

======================================================================
EOT
}