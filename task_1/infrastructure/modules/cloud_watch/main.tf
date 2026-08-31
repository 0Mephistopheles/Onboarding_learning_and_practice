locals {
  parsed_sns_destinations = flatten([
    for destination_name, destination_info in var.sns_destinations : [
      for route_name, route_info in destination_info.route : {
        destination_name = destination_name
        route_name       = route_name
        protocol_name    = route_info.protocol_name
        endpoint         = route_info.endpoint
      }
    ]
  ])

  packed_sns_destinations = {
    for destination in local.parsed_sns_destinations :
    "${destination.destination_name}.${destination.route_name}"
    => destination
  }
}

resource "aws_cloudwatch_metric_alarm" "cloud_watch_alarms" {
  for_each = var.metric_alarms

  alarm_name          = each.value.alarm_name
  alarm_description   = each.value.alarm_description
  comparison_operator = each.value.comparison_operator
  metric_name         = each.value.metric_name
  namespace           = each.value.metric_namespace

  evaluation_periods = each.value.evaluation_periods
  period             = each.value.collection_period
  statistic          = each.value.metric_statistic
  threshold          = each.value.alarm_threshold
  dimensions         = each.value.metric_dimensions

  treat_missing_data = each.value.treat_missing_data
  actions_enabled    = each.value.perform_actions
  alarm_actions      = [aws_sns_topic.sns_topics[each.value.sns_topic_key].arn]
}

resource "aws_sns_topic" "sns_topics" {
  for_each = var.sns_destinations

  name         = each.key
  display_name = each.value.display_name
}

resource "aws_sns_topic_subscription" "sns_targets" {
  for_each = local.packed_sns_destinations

  topic_arn = aws_sns_topic.sns_topics[each.value.destination_name].arn
  protocol  = each.value.protocol_name
  endpoint  = each.value.endpoint
}