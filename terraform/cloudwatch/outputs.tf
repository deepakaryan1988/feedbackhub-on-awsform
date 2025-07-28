output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.ecs.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.ecs.arn
}

output "dashboard_arn" {
  description = "ARN of the CloudWatch dashboard"
  value       = var.create_dashboard ? aws_cloudwatch_dashboard.ecs[0].dashboard_arn : null
}

output "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = var.create_dashboard ? aws_cloudwatch_dashboard.ecs[0].dashboard_name : null
} 