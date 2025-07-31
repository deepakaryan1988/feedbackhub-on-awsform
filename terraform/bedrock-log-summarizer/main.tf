# Bedrock Log Summarizer Module
# This module creates a Lambda function that summarizes ECS logs using AWS Bedrock (Claude Sonnet 4)

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  count = var.summarizer_enabled ? 1 : 0
  name  = "${var.name_prefix}-bedrock-log-summarizer-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM Policy for Lambda
resource "aws_iam_role_policy" "lambda_policy" {
  count  = var.summarizer_enabled ? 1 : 0
  name   = "${var.name_prefix}-bedrock-log-summarizer-policy"
  role   = aws_iam_role.lambda_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel"
        ]
        Resource = "arn:aws:bedrock:*::foundation-model/${var.model_id}"
      },
      {
        Effect = "Allow"
        Action = [
          "bedrock:ListFoundationModels",
          "bedrock:ListInferenceProfiles"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:GetLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "${var.log_group_arn}:*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ]
        Resource = var.s3_bucket_arn != null ? "${var.s3_bucket_arn}/*" : "*"
      }
    ]
  })
}

# Lambda Function
resource "aws_lambda_function" "log_summarizer" {
  count         = var.summarizer_enabled ? 1 : 0
  filename      = data.archive_file.lambda_zip[0].output_path
  function_name = "${var.name_prefix}-bedrock-log-summarizer"
  role          = aws_iam_role.lambda_role[0].arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  timeout       = var.lambda_timeout
  memory_size   = var.lambda_memory_size
  source_code_hash = data.archive_file.lambda_zip[0].output_base64sha256

  environment {
    variables = {
      MODEL_ID           = var.model_id
      LOG_GROUP_NAME     = var.log_group_name
      S3_BUCKET_NAME     = var.s3_bucket_name
      MAX_LOG_LENGTH     = var.max_log_length
      SUMMARY_INTERVAL   = var.summary_interval
    }
  }

  tags = var.tags
}

# Create ZIP file for Lambda
data "archive_file" "lambda_zip" {
  count       = var.summarizer_enabled ? 1 : 0
  type        = "zip"
  source_dir  = "${path.module}/../../lambda/bedrock-log-summarizer"
  output_path = "${path.module}/lambda_function.zip"
  depends_on  = [aws_s3_object.lambda_code]
}

# Upload Lambda code to S3 (for better versioning)
resource "aws_s3_object" "lambda_code" {
  count  = var.summarizer_enabled ? 1 : 0
  bucket = var.s3_bucket_name
  key    = "lambda/bedrock-log-summarizer/${filemd5("${path.module}/../../lambda/bedrock-log-summarizer/lambda_function.py")}/lambda_function.py"
  source = "${path.module}/../../lambda/bedrock-log-summarizer/lambda_function.py"
  etag   = filemd5("${path.module}/../../lambda/bedrock-log-summarizer/lambda_function.py")
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda_logs" {
  count             = var.summarizer_enabled ? 1 : 0
  name              = "/aws/lambda/${aws_lambda_function.log_summarizer[0].function_name}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

# CloudWatch Subscription Filter
resource "aws_cloudwatch_log_subscription_filter" "log_summarizer" {
  count           = var.summarizer_enabled ? 1 : 0
  name            = "${var.name_prefix}-log-summarizer-filter"
  log_group_name  = var.log_group_name
  filter_pattern  = var.filter_pattern
  destination_arn = aws_lambda_function.log_summarizer[0].arn

  distribution = "Random"
}

# Lambda Permission for CloudWatch
resource "aws_lambda_permission" "allow_cloudwatch" {
  count         = var.summarizer_enabled ? 1 : 0
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.log_summarizer[0].function_name
  principal     = "logs.amazonaws.com"
  source_arn    = "${var.log_group_arn}:*"
} 