variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "summarizer_enabled" {
  description = "Enable the Bedrock log summarizer"
  type        = bool
  default     = false
}

variable "model_id" {
  description = "Bedrock model ID to use for summarization (e.g., amazon.titan-text-lite-v1)"
  type        = string
  default     = "amazon.titan-text-lite-v1"
}

variable "log_group_name" {
  description = "Name of the CloudWatch log group to monitor"
  type        = string
}

variable "log_group_arn" {
  description = "ARN of the CloudWatch log group to monitor"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name for storing Lambda code and summaries"
  type        = string
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket for storing summaries"
  type        = string
  default     = null
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 300
}

variable "lambda_memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 512
}

variable "max_log_length" {
  description = "Maximum length of logs to process in characters"
  type        = number
  default     = 10000
}

variable "summary_interval" {
  description = "Interval in minutes to generate summaries"
  type        = number
  default     = 60
}

variable "filter_pattern" {
  description = "CloudWatch log filter pattern"
  type        = string
  default     = ""
}

variable "log_retention_days" {
  description = "Number of days to retain Lambda logs"
  type        = number
  default     = 30
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default     = {}
} 