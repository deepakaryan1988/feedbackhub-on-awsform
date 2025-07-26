output "secret_arn" {
  description = "ARN of the secret in Secrets Manager"
  value       = aws_secretsmanager_secret.mongodb_uri.arn
}

output "secret_name" {
  description = "Name of the secret in Secrets Manager"
  value       = aws_secretsmanager_secret.mongodb_uri.name
}

output "secret_id" {
  description = "ID of the secret in Secrets Manager"
  value       = aws_secretsmanager_secret.mongodb_uri.id
}

output "policy_arn" {
  description = "ARN of the IAM policy for secrets access"
  value       = aws_iam_policy.secrets_access.arn
} 