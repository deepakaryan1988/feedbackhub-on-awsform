resource "aws_sns_topic" "alarms" {
  count = var.sns_topic_arn == "" ? 1 : 0
  name  = "${var.ecs_service_name}-alarms"
  tags  = var.tags
}

locals {
  sns_topic_arn = try(var.sns_topic_arn, aws_sns_topic.alarms[0].arn)
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.ecs_service_name}-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.period
  statistic           = "Average"
  threshold           = var.alarm_cpu_high_threshold
  alarm_description   = "ECS service ${var.ecs_service_name} CPU utilization is high"
  actions_enabled     = var.alarm_actions_enabled
  alarm_actions       = [local.sns_topic_arn]
  ok_actions          = [local.sns_topic_arn]
  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }
  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${var.ecs_service_name}-cpu-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.period
  statistic           = "Average"
  threshold           = var.alarm_cpu_low_threshold
  alarm_description   = "ECS service ${var.ecs_service_name} CPU utilization is low"
  actions_enabled     = var.alarm_actions_enabled
  alarm_actions       = [local.sns_topic_arn]
  ok_actions          = [local.sns_topic_arn]
  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }
  tags = var.tags
}