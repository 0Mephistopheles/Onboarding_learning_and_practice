output "instance_id" {
  value = aws_instance.instance_ec2.id
}

output "private_ip" {
  value = aws_instance.instance_ec2.private_ip
}

output "public_ip" {
  value = aws_instance.instance_ec2.public_ip
}