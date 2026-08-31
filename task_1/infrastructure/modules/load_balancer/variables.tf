variable "load_balancers" {
  type = map(object({
    balancer_name      = string
    balancer_type      = string
    security_group_ids = list(string)
    subnet_ids         = list(string)
    is_internal        = optional(bool, false)
    protect_deletion   = optional(bool, false)
    timeout_limit      = number
  }))
}

variable "target_groups" {
  type = map(object({
    group_name     = string
    group_port     = number
    group_protocol = string
    target_type    = string
    vpc_id         = string
    check_enabled  = optional(bool, true)
    check_path     = string
    check_protocol = string
  }))
}

variable "target_listeners" {
  type = map(object({
    load_balancer_key   = string
    target_group_key    = string
    listener_port       = number
    listener_protocol   = string
    default_action_type = string
  }))
}