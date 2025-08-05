variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "ecs_service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "min_capacity" {
  description = "Minimum number of ECS service tasks"
  type        = number
}

variable "max_capacity" {
  description = "Maximum number of ECS service tasks"
  type        = number
}

variable "target_cpu_utilization" {
  description = "Target average CPU utilization percentage for scaling"
  type        = number
  default     = 70
}

variable "scale_in_cooldown" {
  description = "Cooldown period (seconds) after scale-in"
  type        = number
  default     = 300
}

variable "scale_out_cooldown" {
  description = "Cooldown period (seconds) after scale-out"
  type        = number
  default     = 60
}

variable "enable_scale_in" {
  description = "Whether to enable scale in"
  type        = bool
  default     = true
}

variable "enable_scale_out" {
  description = "Whether to enable scale out"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}