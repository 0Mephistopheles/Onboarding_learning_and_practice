variable "subnet_id" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "associate_public_ip_address" {
  type    = bool
  default = false
}

variable "instance_key" {
  type = string
}

variable "instance_system_type" {
  type = object({
    ami_image_type = string
    instance_type  = optional(string, "t3.micro")
  })
}

variable "instance_volume" {
  type = object({
    volume_size       = optional(number, 8)
    volume_type       = optional(string, "gp3")
    volume_iops       = optional(number)
    volume_throughput = optional(number)
    deletion_policy   = bool
  })
}