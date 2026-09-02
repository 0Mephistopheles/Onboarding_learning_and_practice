locals {
  parsed_security_groups = flatten([
    for group_name, group_info in var.security_groups : [
      for rule_name, rule_info in group_info.rules : {
        group_name = group_name
        rule_name  = rule_name
        rule       = rule_info
      }
    ]
  ])

  packed_rules = {
    for parsed_rule in local.parsed_security_groups :
    "${parsed_rule.group_name}.${parsed_rule.rule_name}" => parsed_rule
  }
}

resource "aws_security_group" "guard" {
  vpc_id      = var.vpc_id
  for_each    = var.security_groups
  name        = each.key
  description = each.value.group_description
}

resource "aws_security_group_rule" "traffic_rules" {
  for_each          = local.packed_rules
  security_group_id = aws_security_group.guard[each.value.group_name].id

  type        = each.value.rule.traffic_type
  description = each.value.rule.description
  cidr_blocks = each.value.rule.source_cidr_blocks
  source_security_group_id = try(
    aws_security_group.guard[
      each.value.rule.source_security_group_id
    ].id,
  null)
  protocol  = each.value.rule.protocol_name
  from_port = each.value.rule.port_range_start
  to_port   = each.value.rule.port_range_end
}
