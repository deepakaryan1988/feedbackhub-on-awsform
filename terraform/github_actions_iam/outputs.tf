output "github_actions_role_arn" {
  value       = aws_iam_role.github_actions_role.arn
  description = "IAM Role ARN for GitHub Actions OIDC"
}
