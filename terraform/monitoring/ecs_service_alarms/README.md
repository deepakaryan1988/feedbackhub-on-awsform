# ECS Service CloudWatch Alarms Module

This module creates CloudWatch alarms for ECS service CPU utilization and sends notifications to an SNS topic.

## Inputs

- `ecs_cluster_name` (string, required): ECS cluster name.
- `ecs_service_name` (string, required): ECS service name.
- `sns_topic_arn` (string, optional): SNS topic ARN for notifications (created if not provided).
- `alarm_cpu_high_threshold` (number, default 80): High CPU threshold.
- `alarm_cpu_low_threshold` (number, default 20): Low CPU threshold.
- `evaluation_periods` (number, default 2): Alarm evaluation periods.
- `period` (number, default 60): Alarm period in seconds.
- `alarm_actions_enabled` (bool, default true): Enable alarm actions.
- `tags` (map(string), optional): Tags to apply.

## Outputs

- `cpu_high_alarm_arn`: ARN of the high CPU alarm.
- `cpu_low_alarm_arn`: ARN of the low CPU alarm.
- `sns_topic_arn`: ARN of the SNS topic used.

## Example Usage

```hcl
module "feedbackhub_alarms" {
  source             = "../terraform/monitoring/ecs_service_alarms"
  ecs_cluster_name   = module.feedbackhub_cluster.cluster_name
  ecs_service_name   = module.feedbackhub_service.service_name
  alarm_cpu_high_threshold = 80
  alarm_cpu_low_threshold  = 20
  tags              = var.tags
}
```