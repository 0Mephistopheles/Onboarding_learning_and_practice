resource "aws_ecs_cluster" "fargate" {
  name = var.cluster_name
}

resource "aws_ecs_task_definition" "fargate_tasks" {
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  for_each = var.fargate_tasks

  family             = each.value.task_family
  cpu                = each.value.task_cpu
  memory             = each.value.task_ram
  execution_role_arn = each.value.execution_role
  task_role_arn      = each.value.task_role

  container_definitions = jsonencode([
    each.value.container_definition
  ])
}

resource "aws_ecs_service" "fargate_services" {
  launch_type = "FARGATE"

  for_each = var.fargate_tasks

  name            = each.value.service_name
  desired_count   = each.value.group_capacity
  cluster         = aws_ecs_cluster.fargate.id
  task_definition = aws_ecs_task_definition.fargate_tasks[each.key].arn

  network_configuration {
    subnets          = each.value.network_configuration.subnets
    security_groups  = each.value.network_configuration.security_groups
    assign_public_ip = each.value.network_configuration.is_public
  }
}

resource "aws_appautoscaling_target" "fargate_target" {
  service_namespace  = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"

  for_each = var.fargate_tasks

  min_capacity = each.value.group_min_size
  max_capacity = each.value.group_max_size
  resource_id  = "service/${aws_ecs_cluster.fargate.name}/${aws_ecs_service.fargate_services[each.key].name}"
}

resource "aws_appautoscaling_policy" "fargate_policy" {
  for_each = var.fargate_tasks

  name               = each.value.policy_name
  service_namespace  = aws_appautoscaling_target.fargate_target[each.key].service_namespace
  scalable_dimension = aws_appautoscaling_target.fargate_target[each.key].scalable_dimension
  resource_id        = aws_appautoscaling_target.fargate_target[each.key].resource_id

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = each.value.policy_configuration.target_value
    scale_in_cooldown  = each.value.policy_configuration.scale_in_cooldown
    scale_out_cooldown = each.value.policy_configuration.scale_out_cooldown
  }
}
