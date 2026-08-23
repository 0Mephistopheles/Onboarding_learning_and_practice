output "security_group_id" {
  value = {
    for name, group in aws_security_group.guard : name => group.id
  }
}

output "security_group_name" {
  value = {
    for name, group in aws_security_group.guard : name => group.name
  }
}

output "security_group_arn" {
  value = {
    for name, group in aws_security_group.guard : name => group.arn
  }
}

output "security_group_vpc_id" {
  value = {
    for name, group in aws_security_group.guard : name => group.vpc_id
  }
}