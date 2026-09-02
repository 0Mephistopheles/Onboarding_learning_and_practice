resource "aws_lb" "balancer" {
  for_each                   = var.load_balancers
  name                       = each.value.balancer_name
  load_balancer_type         = each.value.balancer_type
  internal                   = each.value.is_internal
  security_groups            = each.value.security_group_ids
  subnets                    = each.value.subnet_ids
  enable_deletion_protection = each.value.protect_deletion
  idle_timeout               = each.value.timeout_limit
}

resource "aws_lb_target_group" "balancer_target_group" {
  for_each    = var.target_groups
  name        = each.value.group_name
  port        = each.value.group_port
  protocol    = each.value.group_protocol
  target_type = each.value.target_type
  vpc_id      = each.value.vpc_id

  health_check {
    enabled  = each.value.check_enabled
    path     = each.value.check_path
    protocol = each.value.check_protocol
  }
}

resource "aws_lb_listener" "balancer_listener" {
  for_each          = var.target_listeners
  load_balancer_arn = aws_lb.balancer[each.value.load_balancer_key].arn
  port              = each.value.listener_port
  protocol          = each.value.listener_protocol

  default_action {
    type             = each.value.default_action_type
    target_group_arn = aws_lb_target_group.balancer_target_group[each.value.target_group_key].arn
  }
}