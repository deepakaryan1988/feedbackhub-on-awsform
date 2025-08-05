# Local values for consistent naming
locals {
  name_prefix = "${var.app_name}-${var.environment}"
  common_tags = merge(var.tags, {
    Project     = var.app_name
    Environment = var.environment
    ManagedBy   = "terraform"
  })
}

# ECS Cluster
module "ecs_cluster" {
  source = "../terraform/ecs/cluster"

  cluster_name = "${local.name_prefix}-cluster"
  tags         = local.common_tags
}

# Secrets Manager
module "secrets" {
  source = "../terraform/secrets"

  name_prefix  = local.name_prefix
  mongodb_uri  = var.mongodb_uri
  tags         = local.common_tags
}

# CloudWatch Log Group
module "cloudwatch" {
  source = "../terraform/cloudwatch"

  name_prefix              = local.name_prefix
  log_group_name           = "/ecs/${var.app_name}"
  log_retention_days       = var.log_retention_days
  cluster_name             = module.ecs_cluster.cluster_name
  service_name             = "${var.app_name}-service"
  alb_name                 = "${local.name_prefix}-alb"
  create_dashboard         = var.create_cloudwatch_dashboard
  create_alarms           = var.create_cloudwatch_alarms
  cpu_threshold           = var.cpu_threshold
  memory_threshold        = var.memory_threshold
  tags                    = local.common_tags
}

# Application Load Balancer
module "alb" {
  source = "../terraform/alb"

  name_prefix = local.name_prefix
  vpc_id      = var.vpc_id
  subnet_ids  = var.public_subnet_ids
  target_port = var.app_port
  project_name = var.app_name
  environment  = var.environment
  tags        = local.common_tags
}

# ECS Task Definition
module "ecs_task" {
  source = "../terraform/ecs/feedbackhub"

  container_name      = var.app_name
  ecr_image_url       = var.ecr_image_url
  port                = var.app_port
  cpu                 = var.ecs_cpu
  memory              = var.ecs_memory
  log_group_name      = module.cloudwatch.log_group_name
  log_group_arn       = module.cloudwatch.log_group_arn
  mongodb_secret_arn  = module.secrets.secret_arn
  redeployment_trigger = timestamp()
  tags                = local.common_tags
}

# ECS Service (Blue)
module "ecs_service" {
  source = "../terraform/ecs/feedbackhub_service"

  service_name        = var.app_name
  cluster_id          = module.ecs_cluster.cluster_id
  cluster_name        = module.ecs_cluster.cluster_name
  task_definition_arn = module.ecs_task.task_definition_arn
  subnet_ids          = var.public_subnet_ids
  security_group_id   = module.alb.ecs_tasks_security_group_id
  target_group_arn    = module.alb.target_group_arn
  load_balancer_arn   = module.alb.alb_arn
  container_name      = var.app_name
  container_port      = var.app_port
  desired_count       = var.ecs_desired_count
  min_capacity        = var.ecs_min_capacity
  max_capacity        = var.ecs_max_capacity
  enable_autoscaling  = false
  tags                = local.common_tags
}

# ECS Service Auto Scaling
module "ecs_service_autoscaling" {
  source                 = "../terraform/autoscaling/ecs_service"
  ecs_cluster_name       = module.ecs_cluster.cluster_name
  ecs_service_name       = module.ecs_service.service_name
  min_capacity           = var.ecs_min_capacity
  max_capacity           = var.ecs_max_capacity
  target_cpu_utilization = var.cpu_threshold
  scale_in_cooldown      = 300
  scale_out_cooldown     = 60
  tags                   = local.common_tags
}

# ECS Service Monitoring/Alarms
module "ecs_service_alarms" {
  source                   = "../terraform/monitoring/ecs_service_alarms"
  ecs_cluster_name         = module.ecs_cluster.cluster_name
  ecs_service_name         = module.ecs_service.service_name
  alarm_cpu_high_threshold = 80
  alarm_cpu_low_threshold  = 20
  tags                     = local.common_tags
}

# SNS Email Subscriptions for Alarms
module "sns_subscriptions" {
  source = "../terraform/monitoring/sns_subscriptions"
  
  sns_topic_arn = module.ecs_service_alarms.sns_topic_arn
  email_addresses = var.notification_emails
  tags = local.common_tags
}

# ECS Service (Green)
module "ecs_service_green" {
  source = "../terraform/ecs/feedbackhub_service_green"

  project_name         = var.app_name
  ecs_cluster_id       = module.ecs_cluster.cluster_id
  task_definition_arn  = module.ecs_task.task_definition_arn
  subnet_ids           = var.public_subnet_ids
  security_group_id    = module.alb.ecs_tasks_security_group_id
  green_target_group_arn = module.alb.feedbackhub_green_tg_arn
  container_name       = var.app_name
  container_port       = var.app_port
}

# S3 Bucket for Lambda code and log summaries
resource "aws_s3_bucket" "lambda_and_summaries" {
  bucket = "${local.name_prefix}-lambda-summaries"

  tags = local.common_tags
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "lambda_and_summaries" {
  bucket = aws_s3_bucket.lambda_and_summaries.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Server Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "lambda_and_summaries" {
  bucket = aws_s3_bucket.lambda_and_summaries.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "lambda_and_summaries" {
  bucket = aws_s3_bucket.lambda_and_summaries.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

module "github_actions_iam" {
  source        = "../terraform/github_actions_iam"
  aws_region    = var.aws_region
  project_name  = "feedbackhub"
  github_repo   = "deepakaryan1988/feedbackhub-on-awsform"
}

# Bedrock Log Summarizer Module
module "bedrock_log_summarizer" {
  source = "../terraform/bedrock-log-summarizer"

  name_prefix        = local.name_prefix
  summarizer_enabled = var.bedrock_summarizer_enabled
  model_id           = var.bedrock_model_id
  log_group_name     = module.cloudwatch.log_group_name
  log_group_arn      = module.cloudwatch.log_group_arn
  s3_bucket_name     = aws_s3_bucket.lambda_and_summaries.bucket
  s3_bucket_arn      = aws_s3_bucket.lambda_and_summaries.arn
  lambda_timeout     = var.bedrock_lambda_timeout
  lambda_memory_size = var.bedrock_lambda_memory_size
  max_log_length     = var.bedrock_max_log_length
  summary_interval   = var.bedrock_summary_interval
  filter_pattern     = var.bedrock_filter_pattern
  log_retention_days = var.log_retention_days
  tags               = local.common_tags
}
