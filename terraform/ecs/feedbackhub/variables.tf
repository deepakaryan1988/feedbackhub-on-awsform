variable "container_name" {
  description = "The name of the container."
  type        = string
}

variable "ecr_image_url" {
  description = "The URL of the ECR image."
  type        = string
}

variable "port" {
  description = "The port to expose on the container."
  type        = number
}

variable "cpu" {
  description = "The CPU units to reserve for the container."
  type        = number
}

variable "memory" {
  description = "The memory to reserve for the container."
  type        = number
}

variable "log_group_name" {
  description = "The name of the CloudWatch log group."
  type        = string
}

variable "log_group_arn" {
  description = "The ARN of the CloudWatch log group."
  type        = string
}

variable "mongodb_secret_arn" {
  description = "The ARN of the Secrets Manager secret for the MongoDB URI."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}

variable "redeployment_trigger" {
  description = "A value that, when changed, triggers a redeployment of the ECS service."
  type        = string
  default     = ""
}