output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = var.summarizer_enabled ? aws_lambda_function.log_summarizer[0].arn : null
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = var.summarizer_enabled ? aws_lambda_function.log_summarizer[0].function_name : null
}

output "lambda_role_arn" {
  description = "ARN of the Lambda IAM role"
  value       = var.summarizer_enabled ? aws_iam_role.lambda_role[0].arn : null
}

output "lambda_log_group_name" {
  description = "Name of the Lambda CloudWatch log group"
  value       = var.summarizer_enabled ? aws_cloudwatch_log_group.lambda_logs[0].name : null
}

output "subscription_filter_name" {
  description = "Name of the CloudWatch subscription filter"
  value       = var.summarizer_enabled ? aws_cloudwatch_log_subscription_filter.log_summarizer[0].name : null
} 