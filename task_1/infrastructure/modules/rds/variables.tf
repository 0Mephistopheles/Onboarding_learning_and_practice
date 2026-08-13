variable "private_subnet_ids" {
  type = list(string)
}

variable "vpc_security_groups" {
  type = list(string)
}

variable "db_type" {
  type = object({
    db_engine  = optional(string, "postgres")
    db_version = optional(string, "16.4")
    db_class   = optional(string, "db.t4g.micro")
  })
}

variable "db_storage" {
  type = object({
    storage_size = optional(number, 10)
    storage_type = optional(string, "gp3")
  })
}

variable "db_user" {
  type = object({
    db_name       = optional(string, "db_instance")
    user_name     = optional(string, "admin")
    user_password = string
  })
  sensitive = true
}

variable "db_port" {
  type    = number
  default = 5432
}

variable "is_multi_az" {
  type    = bool
  default = false
}

variable "public_access" {
  type    = bool
  default = false
}