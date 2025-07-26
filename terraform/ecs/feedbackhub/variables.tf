variable "container_name" {
  description = "Name of the container"
  type        = string
}

variable "ecr_image_url" {
  description = "ECR image URL for the container"
  type        = string
}

variable "port" {
  description = "Port the container listens on"
  type        = number
  default     = 3000
}

variable "cpu" {
  description = "CPU units for the task (1024 = 1 vCPU)"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Memory for the task in MiB"
  type        = number
  default     = 512
}

variable "log_group_name" {
  description = "Name of the CloudWatch log group"
  type        = string
}

variable "log_group_arn" {
  description = "ARN of the CloudWatch log group"
  type        = string
}



variable "mongodb_secret_arn" {
  description = "ARN of the MongoDB URI secret in Secrets Manager"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default     = {}
} 