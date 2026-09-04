locals {
  parsed_iam_profiles = flatten([
    for role_key, role_info in var.role_profiles : [
      for policy_key in role_info.policies : {
        role_key   = role_key
        role_name  = role_info.role_name
        policy_key = policy_key
      }
    ]
  ])

  packed_policy_info = {
    for iam_info in local.parsed_iam_profiles :
    "${iam_info.role_key}.${iam_info.policy_key}" => iam_info
  }
}

resource "aws_iam_role" "role" {
  for_each = var.role_profiles

  name = each.value.role_name

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : each.value.allowed_services
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "policy" {
  for_each = var.policy_profiles

  name = each.value.policy_name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : each.value.policy_actions,
        "Resource" : each.value.policy_resources
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  for_each = local.packed_policy_info

  role       = aws_iam_role.role[each.value.role_key].name
  policy_arn = aws_iam_policy.policy[each.value.policy_key].arn
}
