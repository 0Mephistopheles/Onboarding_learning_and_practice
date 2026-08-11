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

variable "destination_cidr_block" {
  type    = string
  default = "0.0.0.0/0"
}

variable "enable_nat" {
  type    = bool
  default = false
}