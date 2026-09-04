variable "role_profiles" {
  type = map(object({
    role_name        = string
    allowed_services = list(string)
    policies         = list(string)
  }))
}


variable "policy_profiles" {
  type = map(object({
    policy_name      = string
    policy_actions   = list(string)
    policy_resources = list(string)
  }))
}
