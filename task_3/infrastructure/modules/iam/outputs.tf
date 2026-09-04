output "role_arns" {
  value = {
    for role_key, role in aws_iam_role.role :
    role_key => role.arn
  }
}

output "policy_arns" {
  value = {
    for policy_key, policy in aws_iam_policy.policy :
    policy_key => policy.arn
  }
}
