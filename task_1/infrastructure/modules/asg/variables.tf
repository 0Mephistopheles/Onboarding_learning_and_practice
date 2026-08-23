variable "launch_template_name" {
  type = string
}

variable "group_name" {
  type = string
}

variable "instance_system_type" {
  type = object({
    ami_image_type = string
    instance_type  = optional(string, "t3.micro")
  })
}

variable "instance_key" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "subnet_ids" {
  type = list(string)
}

variable "device_root" {
  type = string
}

variable "instance_volume" {
  type = object({
    volume_size           = optional(number, 8)
    volume_type           = optional(string, "gp3")
    delete_on_termination = optional(bool, true)
  })
}

variable "group_min_size" {
  type = number
}

variable "group_max_size" {
  type = number
}

variable "group_capacity" {
  type = number
}

variable "check_type" {
  type = string
}

variable "check_period" {
  type = number
}

variable "enable_scaling" {
  type    = bool
  default = false
}

variable "scaling_policy_name" {
  type = string
}

variable "scaling_type" {
  type = string
}

variable "cpu_threshold" {
  type = number
}