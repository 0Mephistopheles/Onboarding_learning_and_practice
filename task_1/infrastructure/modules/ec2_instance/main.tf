resource "aws_instance" "instance_ec2" {
  ami           = var.instance_system_type.ami_image_type
  instance_type = var.instance_system_type.instance_type

  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = var.associate_public_ip_address
  key_name                    = var.instance_key

  root_block_device {
    volume_size = var.instance_volume.volume_size
    volume_type = var.instance_volume.volume_type
    iops        = var.instance_volume.volume_iops
    throughput  = var.instance_volume.volume_throughput
    delete_on_termination = var.instance_volume.deletion_policy
  }
}
