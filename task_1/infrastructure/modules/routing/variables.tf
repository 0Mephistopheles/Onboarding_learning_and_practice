variable "vpc_id" {
  type = string
}

variable "internet_gateway_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "enable_nat" {
  type    = bool
  default = false
}