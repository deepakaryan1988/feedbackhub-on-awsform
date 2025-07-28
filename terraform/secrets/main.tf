# AWS Secrets Manager secret for MongoDB URI
resource "aws_secretsmanager_secret" "mongodb_uri" {
  name        = var.secret_name
  description = "MongoDB connection URI for FeedbackHub application"

  tags = merge(var.tags, {
    Name = var.secret_name
  })
}

# Secret version with the actual MongoDB URI
resource "aws_secretsmanager_secret_version" "mongodb_uri" {
  secret_id     = aws_secretsmanager_secret.mongodb_uri.id
  secret_string = var.mongodb_uri
}

# IAM policy for ECS tasks to access the secret
resource "aws_iam_policy" "secrets_access" {
  name        = "${var.name_prefix}-secrets-access-policy"
  description = "Policy to allow ECS tasks to access Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = aws_secretsmanager_secret.mongodb_uri.arn
      }
    ]
  })

  tags = var.tags
} 