variable "name" {
  type = string
}

variable "description" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "rules" {
  type = map(object({
    traffic_type = optional(string, "ingress")
    rule_description = optional(string, "")
    source_security_group_id = optional(string)
    source_cidr_blocks = optional(list(string))
    port_range_start = number
    port_range_end = number
    protocol_name = optional(string, "tcp")
  }))
}