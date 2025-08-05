output "autoscaling_policy_arn" {
  description = "ARN of the ECS service auto scaling policy"
  value       = aws_appautoscaling_policy.cpu_target_tracking.arn
}

output "scalable_target_arn" {
  description = "ARN of the ECS service scalable target"
  value       = aws_appautoscaling_target.ecs_service.arn
}