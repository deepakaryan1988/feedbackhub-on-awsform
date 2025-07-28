variable "aws_region" {
  type        = string
  description = "AWS region to deploy the IAM role"
}

variable "project_name" {
  type        = string
  description = "Project name prefix"
}

variable "github_repo" {
  type        = string
  description = "GitHub repository in format owner/repo"
}
