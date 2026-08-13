resource "aws_security_group" "guard" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "traffic_rules" {
  security_group_id = aws_security_group.guard.id
  for_each          = var.rules

  type                     = each.value.traffic_type
  description              = each.value.rule_description
  cidr_blocks              = each.value.source_cidr_blocks
  source_security_group_id = each.value.source_security_group_id

  protocol  = each.value.protocol_name
  from_port = each.value.port_range_start
  to_port   = each.value.port_range_end
}