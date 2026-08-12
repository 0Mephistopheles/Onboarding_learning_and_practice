output "security_group_id" {
  value = aws_security_group.guard.id
}

output "security_group_name" {
  value = aws_security_group.guard.name
}

output "security_group_arn" {
  value = aws_security_group.guard.arn
}

output "security_group_vpc_id" {
  value = aws_security_group.guard.vpc_id
}