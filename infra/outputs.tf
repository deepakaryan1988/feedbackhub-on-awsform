# ECS Outputs
output "ecs_cluster_id" {
  description = "ID of the ECS cluster"
  value       = module.ecs_cluster.cluster_id
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs_cluster.cluster_name
}

output "ecs_service_name" {
  description = "Name of the ECS service (Blue)"
  value       = module.ecs_service.service_name
}

output "ecs_green_service_name" {
  description = "Name of the ECS service (Green)"
  value       = module.ecs_service_green.green_service_name
}

output "ecs_task_definition_arn" {
  description = "ARN of the ECS task definition"
  value       = module.ecs_task.task_definition_arn
}

# ALB Outputs
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = module.alb.alb_zone_id
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = module.alb.target_group_arn
}

# CloudWatch Outputs
output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = module.cloudwatch.log_group_name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = module.cloudwatch.log_group_arn
}

output "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = module.cloudwatch.dashboard_name
}

# Secrets Outputs
output "secret_arn" {
  description = "ARN of the MongoDB URI secret"
  value       = module.secrets.secret_arn
}

output "secret_name" {
  description = "Name of the MongoDB URI secret"
  value       = module.secrets.secret_name
}

# GitHub Actions IAM Outputs
output "github_actions_role_arn" {
  description = "ARN of the IAM role for GitHub Actions OIDC"
  value       = module.github_actions_iam.github_actions_role_arn
}

# S3 Bucket Outputs
output "lambda_summaries_bucket_name" {
  description = "Name of the S3 bucket for Lambda code and summaries"
  value       = aws_s3_bucket.lambda_and_summaries.bucket
}

output "lambda_summaries_bucket_arn" {
  description = "ARN of the S3 bucket for Lambda code and summaries"
  value       = aws_s3_bucket.lambda_and_summaries.arn
}

# Bedrock Log Summarizer Outputs
output "bedrock_lambda_function_arn" {
  description = "ARN of the Bedrock log summarizer Lambda function"
  value       = module.bedrock_log_summarizer.lambda_function_arn
}

output "bedrock_lambda_function_name" {
  description = "Name of the Bedrock log summarizer Lambda function"
  value       = module.bedrock_log_summarizer.lambda_function_name
}

output "bedrock_lambda_role_arn" {
  description = "ARN of the Bedrock log summarizer Lambda IAM role"
  value       = module.bedrock_log_summarizer.lambda_role_arn
}

output "bedrock_lambda_log_group_name" {
  description = "Name of the Bedrock log summarizer Lambda CloudWatch log group"
  value       = module.bedrock_log_summarizer.lambda_log_group_name
}

output "bedrock_subscription_filter_name" {
  description = "Name of the CloudWatch subscription filter for log summarization"
  value       = module.bedrock_log_summarizer.subscription_filter_name
}

# Application URL
output "application_url" {
  description = "URL to access the application"
  value       = "http://${module.alb.alb_dns_name}"
} 