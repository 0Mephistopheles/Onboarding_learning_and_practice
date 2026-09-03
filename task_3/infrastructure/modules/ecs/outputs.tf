output "cluster_id" {
  value = aws_ecs_cluster.fargate.id
}

output "cluster_name" {
  value = aws_ecs_cluster.fargate.name
}

output "task_definition_arns" {
  value = {
    for key, task in aws_ecs_task_definition.fargate_tasks :
    key => task.arn
  }
}

output "service_names" {
  value = {
    for key, service in aws_ecs_service.fargate_services :
    key => service.name
  }
}