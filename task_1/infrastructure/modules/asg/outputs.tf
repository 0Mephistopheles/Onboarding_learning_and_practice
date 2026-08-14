output "autoscaling_group_id" {
  value = aws_autoscaling_group.scaling_plan.id
}

output "autoscaling_group_name" {
  value = aws_autoscaling_group.scaling_plan.name
}

output "launch_template_id" {
  value = aws_launch_template.launch_plan.id
}

output "launch_template_latest_version" {
  value = aws_launch_template.launch_plan.latest_version
}

output "autoscaling_group_arn" {
  value = aws_autoscaling_group.scaling_plan.arn
}