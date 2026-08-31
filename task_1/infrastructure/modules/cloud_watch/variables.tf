variable "metric_alarms" {
  type = map(object({
    alarm_name          = string
    alarm_description   = string
    comparison_operator = string
    metric_name         = string
    metric_namespace    = string
    evaluation_periods  = number
    collection_period   = number
    metric_statistic    = string
    alarm_threshold     = number
    metric_dimensions   = map(string)
    treat_missing_data  = string
    perform_actions     = optional(bool, true)
    sns_topic_key       = string
  }))
}

variable "sns_destinations" {
  type = map(object({
    display_name = string
    route = map(object({
      protocol_name = string
      endpoint      = string
    }))
  }))
}
