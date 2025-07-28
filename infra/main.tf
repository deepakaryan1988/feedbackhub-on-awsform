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

# ECS Service
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