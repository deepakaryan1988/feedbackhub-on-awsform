# ECS Service Auto Scaling Module

This module enables target tracking auto scaling for an ECS service using CPU utilization.

## Inputs

- `ecs_cluster_name` (string, required): Name of the ECS cluster.
- `ecs_service_name` (string, required): Name of the ECS service.
- `min_capacity` (number, required): Minimum number of tasks.
- `max_capacity` (number, required): Maximum number of tasks.
- `target_cpu_utilization` (number, default 70): Target CPU utilization (%).
- `scale_in_cooldown` (number, default 300): Cooldown after scale-in (seconds).
- `scale_out_cooldown` (number, default 60): Cooldown after scale-out (seconds).
- `enable_scale_in` (bool, default true): Enable scale in.
- `enable_scale_out` (bool, default true): Enable scale out.
- `tags` (map(string), optional): Tags to apply.

## Outputs

- `autoscaling_policy_arn`: ARN of the scaling policy.
- `scalable_target_arn`: ARN of the scalable target.

## Example Usage

```hcl
module "feedbackhub_autoscaling" {
  source                = "../terraform/autoscaling/ecs_service"
  ecs_cluster_name      = module.feedbackhub_cluster.cluster_name
  ecs_service_name      = module.feedbackhub_service.service_name
  min_capacity          = 2
  max_capacity          = 10
  target_cpu_utilization = 70
  scale_in_cooldown     = 300
  scale_out_cooldown    = 60
  tags                  = var.tags
}
```