# AWS Configuration
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

# VPC Configuration
variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB and ECS"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS (optional)"
  type        = list(string)
  default     = []
}

# Application Configuration
variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "feedbackhub"
}

variable "ecr_image_url" {
  description = "ECR image URL for the application"
  type        = string
}

variable "mongodb_uri" {
  description = "MongoDB connection URI"
  type        = string
  sensitive   = true
}

variable "app_port" {
  description = "Port the application listens on"
  type        = number
  default     = 3000
}

# ECS Configuration
variable "ecs_cpu" {
  description = "CPU units for ECS tasks (1024 = 1 vCPU)"
  type        = number
  default     = 256
}

variable "ecs_memory" {
  description = "Memory for ECS tasks in MiB"
  type        = number
  default     = 512
}

variable "ecs_desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 2
}

variable "ecs_min_capacity" {
  description = "Minimum number of ECS tasks for auto scaling"
  type        = number
  default     = 1
}

variable "ecs_max_capacity" {
  description = "Maximum number of ECS tasks for auto scaling"
  type        = number
  default     = 10
}

variable "enable_autoscaling" {
  description = "Enable auto-scaling for ECS service"
  type        = bool
  default     = true
}

# Monitoring Configuration
variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}

variable "create_cloudwatch_dashboard" {
  description = "Create CloudWatch dashboard"
  type        = bool
  default     = true
}

variable "create_cloudwatch_alarms" {
  description = "Create CloudWatch alarms"
  type        = bool
  default     = true
}

variable "cpu_threshold" {
  description = "CPU utilization threshold for alarms"
  type        = number
  default     = 80
}

variable "memory_threshold" {
  description = "Memory utilization threshold for alarms"
  type        = number
  default     = 80
}

# Tags
variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
} 