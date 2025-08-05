variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "ecs_service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for alarm notifications (if not provided, one will be created)"
  type        = string
  default     = ""
}

variable "alarm_cpu_high_threshold" {
  description = "CPU utilization threshold for high alarm"
  type        = number
  default     = 80
}

variable "alarm_cpu_low_threshold" {
  description = "CPU utilization threshold for low alarm"
  type        = number
  default     = 20
}

variable "evaluation_periods" {
  description = "Number of periods to evaluate for the alarm"
  type        = number
  default     = 2
}

variable "period" {
  description = "Period (in seconds) over which the specified statistic is applied"
  type        = number
  default     = 60
}

variable "alarm_actions_enabled" {
  description = "Whether to enable alarm actions"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}