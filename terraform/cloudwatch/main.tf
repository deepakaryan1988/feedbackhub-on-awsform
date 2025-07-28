# CloudWatch Log Group for ECS
resource "aws_cloudwatch_log_group" "ecs" {
  name              = var.log_group_name
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name = var.log_group_name
  })
}

# CloudWatch Dashboard for ECS monitoring
resource "aws_cloudwatch_dashboard" "ecs" {
  count          = var.create_dashboard ? 1 : 0
  dashboard_name = "${var.name_prefix}-ecs-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", var.service_name, "ClusterName", var.cluster_name],
            [".", "MemoryUtilization", ".", ".", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = data.aws_region.current.name
          title  = "ECS Service Metrics"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_name],
            [".", "TargetResponseTime", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = data.aws_region.current.name
          title  = "ALB Metrics"
        }
      }
    ]
  })
}

# CloudWatch Alarm for high CPU utilization
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count               = var.create_alarms ? 1 : 0
  alarm_name          = "${var.name_prefix}-cpu-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.cpu_threshold
  alarm_description   = "This metric monitors ECS CPU utilization"
  alarm_actions       = var.alarm_actions

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }

  tags = var.tags
}

# CloudWatch Alarm for high memory utilization
resource "aws_cloudwatch_metric_alarm" "memory_high" {
  count               = var.create_alarms ? 1 : 0
  alarm_name          = "${var.name_prefix}-memory-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.memory_threshold
  alarm_description   = "This metric monitors ECS memory utilization"
  alarm_actions       = var.alarm_actions

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }

  tags = var.tags
}

# Data source for current region
data "aws_region" "current" {} 