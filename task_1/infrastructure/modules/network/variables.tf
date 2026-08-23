variable "virtual_private_clouds" {
  type = map(object({
    vpc_cidr             = string
    enable_dns_hostnames = optional(bool, false)
    enable_dns_support   = optional(bool, false)

    vpc_subnets = map(object({
      type              = string
      subnet_cidr       = string
      availability_zone = string
    }))

    routing_configuration = object({
      destination_cidr_block = optional(string, "0.0.0.0/0")
      enable_nat             = optional(bool, false)
      nat_location_name      = optional(string, "subnet_1")
    })
  }))
}
