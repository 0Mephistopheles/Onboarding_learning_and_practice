output "target_group_arns" {
  value = {
    for key, target_group in aws_lb_target_group.balancer_target_group :
    key => target_group.arn
  }
}

output "load_balancer_id" {
  value = {
    for key, lb in aws_lb.balancer :
    key => lb.arn_suffix
  }
}

output "target_group_id" {
  value = {
    for key, target_group in aws_lb_target_group.balancer_target_group :
    key => target_group.arn_suffix
  }
}
