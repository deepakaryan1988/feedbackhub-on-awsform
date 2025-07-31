# Bedrock Log Summarizer Module

This Terraform module creates a Lambda function that summarizes ECS application logs using AWS Bedrock (Claude Sonnet 4). The module is designed to be cost-controlled and only enabled when explicitly needed.

## Architecture

```
ECS → CloudWatch Log Group → Subscription Filter → Lambda → Bedrock (Claude Sonnet 4) → Summary to CloudWatch Logs / S3
```

## Features

- **Cost Control**: Disabled by default (`summarizer_enabled = false`)
- **Log Truncation**: Configurable maximum log length to control Bedrock API costs
- **S3 Storage**: Optional storage of summaries in S3 bucket
- **CloudWatch Integration**: Real-time log processing via subscription filters
- **Configurable Model**: Support for different Bedrock models
- **Error Handling**: Comprehensive error handling and logging

## Usage

### Basic Configuration (Disabled by Default)

```hcl
module "bedrock_log_summarizer" {
  source = "../terraform/bedrock-log-summarizer"

  name_prefix        = "myapp-prod"
  summarizer_enabled = false  # Disabled by default for cost control
  log_group_name     = "/ecs/myapp"
  log_group_arn      = "arn:aws:logs:us-east-1:123456789012:log-group:/ecs/myapp:*"
  s3_bucket_name     = "myapp-lambda-summaries"
  s3_bucket_arn      = "arn:aws:s3:::myapp-lambda-summaries"
  tags               = { Environment = "production" }
}
```

### Enabled Configuration

```hcl
module "bedrock_log_summarizer" {
  source = "../terraform/bedrock-log-summarizer"

  name_prefix        = "myapp-prod"
  summarizer_enabled = true  # Explicitly enable
  model_id           = "anthropic.claude-3-sonnet-20240229-v1:0"
  log_group_name     = "/ecs/myapp"
  log_group_arn      = "arn:aws:logs:us-east-1:123456789012:log-group:/ecs/myapp:*"
  s3_bucket_name     = "myapp-lambda-summaries"
  s3_bucket_arn      = "arn:aws:s3:::myapp-lambda-summaries"
  max_log_length     = 8000  # Control costs
  summary_interval   = 30    # Generate summaries every 30 minutes
  tags               = { Environment = "production" }
}
```

## Variables

| Variable | Description | Type | Default | Required |
|----------|-------------|------|---------|----------|
| `name_prefix` | Prefix for resource names | `string` | - | Yes |
| `summarizer_enabled` | Enable the Bedrock log summarizer | `bool` | `false` | No |
| `model_id` | Bedrock model ID for summarization | `string` | `"anthropic.claude-3-sonnet-20240229-v1:0"` | No |
| `log_group_name` | Name of the CloudWatch log group to monitor | `string` | - | Yes |
| `log_group_arn` | ARN of the CloudWatch log group to monitor | `string` | - | Yes |
| `s3_bucket_name` | S3 bucket name for storing Lambda code and summaries | `string` | - | Yes |
| `s3_bucket_arn` | ARN of the S3 bucket for storing summaries | `string` | `null` | No |
| `lambda_timeout` | Lambda function timeout in seconds | `number` | `300` | No |
| `lambda_memory_size` | Lambda function memory size in MB | `number` | `512` | No |
| `max_log_length` | Maximum length of logs to process in characters | `number` | `10000` | No |
| `summary_interval` | Interval in minutes to generate summaries | `number` | `60` | No |
| `filter_pattern` | CloudWatch log filter pattern | `string` | `""` | No |
| `log_retention_days` | Number of days to retain Lambda logs | `number` | `30` | No |
| `tags` | A map of tags to assign to resources | `map(string)` | `{}` | No |

## Outputs

| Output | Description |
|--------|-------------|
| `lambda_function_arn` | ARN of the Lambda function |
| `lambda_function_name` | Name of the Lambda function |
| `lambda_role_arn` | ARN of the Lambda IAM role |
| `lambda_log_group_name` | Name of the Lambda CloudWatch log group |
| `subscription_filter_name` | Name of the CloudWatch subscription filter |

## IAM Permissions

The Lambda function requires the following permissions:

- **CloudWatch Logs**: `logs:CreateLogGroup`, `logs:CreateLogStream`, `logs:PutLogEvents`
- **Bedrock**: `bedrock:InvokeModel` for the specified model
- **CloudWatch Logs (Read)**: `logs:GetLogEvents`, `logs:DescribeLogStreams`
- **S3**: `s3:PutObject` for storing summaries

## Cost Considerations

1. **Bedrock API Costs**: Each log summary costs money based on the model used
2. **Lambda Execution**: Standard Lambda pricing applies
3. **S3 Storage**: Minimal costs for storing summaries
4. **CloudWatch**: Standard CloudWatch pricing for logs

### Cost Control Strategies

1. **Disable by Default**: Module is disabled by default
2. **Log Truncation**: Use `max_log_length` to limit input size
3. **Summary Intervals**: Use `summary_interval` to control frequency
4. **Filter Patterns**: Use `filter_pattern` to process only relevant logs

## Lambda Function Features

The Lambda function (`lambda_function.py`) includes:

- **Log Extraction**: Processes CloudWatch subscription events
- **Cost Control**: Truncates logs to specified length
- **Bedrock Integration**: Calls Claude Sonnet 4 for summarization
- **S3 Storage**: Optionally saves summaries to S3
- **Error Handling**: Comprehensive error handling and logging
- **Configurable**: Environment variables for customization

## Security

- S3 bucket has encryption enabled
- Public access is blocked on S3 bucket
- IAM roles follow least privilege principle
- Lambda function runs in VPC (if configured)

## Monitoring

- Lambda function logs are available in CloudWatch
- S3 bucket access logs can be enabled
- CloudWatch metrics for Lambda execution
- Error tracking through CloudWatch logs

## Troubleshooting

1. **Lambda Timeout**: Increase `lambda_timeout` if summaries take too long
2. **Memory Issues**: Increase `lambda_memory_size` if needed
3. **Bedrock Errors**: Check IAM permissions and model availability
4. **S3 Errors**: Verify bucket permissions and configuration

## Example Integration

See `infra/main.tf` for complete integration example with the FeedbackHub project. 