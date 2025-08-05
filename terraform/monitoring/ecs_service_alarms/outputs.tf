output "cpu_high_alarm_arn" {
  description = "ARN of the high CPU CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.cpu_high.arn
}

output "cpu_low_alarm_arn" {
  description = "ARN of the low CPU CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.cpu_low.arn
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic used for notifications"
  value       = local.sns_topic_arn
}