output "sns_topic_arn" {
  description = "SNS Topic ARN for alerts"
  value       = aws_sns_topic.alerts.arn
}

output "sns_topic_name" {
  description = "SNS Topic name"
  value       = aws_sns_topic.alerts.name
}

output "cpu_critical_alarm_arn" {
  description = "CloudWatch Alarm ARN for critical CPU (> 80%)"
  value       = aws_cloudwatch_metric_alarm.cpu_critical.arn
}

output "unhealthy_targets_alarm_arn" {
  description = "CloudWatch Alarm ARN for unhealthy targets"
  value       = aws_cloudwatch_metric_alarm.unhealthy_targets.arn
}

output "high_response_time_alarm_arn" {
  description = "CloudWatch Alarm ARN for high response time"
  value       = aws_cloudwatch_metric_alarm.high_response_time.arn
}

output "http_5xx_errors_alarm_arn" {
  description = "CloudWatch Alarm ARN for 5XX errors"
  value       = aws_cloudwatch_metric_alarm.http_5xx_errors.arn
}

output "app_errors_alarm_arn" {
  description = "CloudWatch Alarm ARN for application errors"
  value       = aws_cloudwatch_metric_alarm.app_errors.arn
}
