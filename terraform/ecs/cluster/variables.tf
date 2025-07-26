variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the cluster"
  type        = map(string)
  default     = {}
} 