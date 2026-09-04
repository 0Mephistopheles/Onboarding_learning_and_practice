variable "cluster_name" {
  type = string
}

variable "fargate_tasks" {
  type = map(object({
    task_family    = string
    task_cpu       = string
    task_ram       = string
    task_role      = optional(string)
    execution_role = string

    container_definition = object({
      name  = string
      image = string

      portMappings = list(object({
        containerPort = number
        hostPort      = number
        protocol      = optional(string, "tcp")
      }))

      healthCheck = optional(object({
        command     = list(string)
        interval    = number
        timeout     = number
        retries     = number
        startPeriod = number
      }))
    })

    service_name   = string
    group_capacity = number

    network_configuration = object({
      subnets         = list(string)
      security_groups = list(string)
      is_public       = optional(bool, false)
    })

    group_min_size = number
    group_max_size = number

    policy_name = string
    policy_configuration = object({
      target_value       = number
      scale_in_cooldown  = number
      scale_out_cooldown = number
    })
  }))
}