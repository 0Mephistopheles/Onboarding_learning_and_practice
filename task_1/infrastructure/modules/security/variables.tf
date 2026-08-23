variable "vpc_id" {
  type = string
}

variable "security_groups" {
  type = map(object({
    group_description = string
    rules = map(object({
      traffic_type             = optional(string, "ingress")
      description              = optional(string, "")
      source_security_group_id = optional(string)
      source_cidr_blocks       = optional(list(string))
      port_range_start         = number
      port_range_end           = number
      protocol_name            = optional(string, "tcp")
    }))
  }))
}