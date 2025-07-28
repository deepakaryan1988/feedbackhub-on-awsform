variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "secret_name" {
  description = "Name of the secret in Secrets Manager"
  type        = string
  default     = "feedbackhub/mongodb_uri"
}

variable "mongodb_uri" {
  description = "MongoDB connection URI to store in Secrets Manager"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default     = {}
} 