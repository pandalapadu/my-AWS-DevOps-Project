output "ec2_instance_output" {
  value = {
    instance_id = aws_instance.roboshop[*].id
    public_ip   = aws_instance.roboshop[*].public_ip
    private_ip  = aws_instance.roboshop[*].private_ip
  }
}