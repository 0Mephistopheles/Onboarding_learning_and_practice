output "volume_id" {
  value = aws_efs_file_system.volume_system.id
}

output "access_point_ids" {
  value = {
    for key, point in aws_efs_access_point.volume_access :
    key => point.id
  }
}