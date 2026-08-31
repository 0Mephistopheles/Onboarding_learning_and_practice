output "sns_topic_arns" {
  value = {
    for key, topic in aws_sns_topic.sns_topics :
    key => topic.arn
  }
}

output "alarm_arns" {
  value = {
    for key, alarm in aws_cloudwatch_metric_alarm.cloud_watch_alarms :
    key => alarm.arn
  }
}