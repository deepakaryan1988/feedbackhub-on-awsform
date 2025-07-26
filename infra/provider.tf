terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "feedbackhub"
      Environment = var.environment
      ManagedBy   = "terraform"
      Owner       = "devops"
    }
  }
} 