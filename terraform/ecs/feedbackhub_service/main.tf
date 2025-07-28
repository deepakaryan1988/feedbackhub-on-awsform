resource "aws_ecs_service" "app" {
  name            = "${var.service_name}-service"
  cluster         = var.cluster_id
  task_definition = var.task_definition_arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  health_check_grace_period_seconds = 300

  tags = var.tags
}

# Auto Scaling
resource "aws_appautoscaling_target" "ecs_target" {
  count              = var.enable_autoscaling ? 1 : 0
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# CPU-based auto scaling
resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  count              = var.enable_autoscaling ? 1 : 0
  name               = "${var.service_name}-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = var.cpu_target_value
  }
}

# Memory-based auto scaling
resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  count              = var.enable_autoscaling ? 1 : 0
  name               = "${var.service_name}-memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value = var.memory_target_value
  }
} 