# SNS Subscriptions Module

This module creates email subscriptions to SNS topics for notifications.

## Inputs

- `sns_topic_arn` (string, required): ARN of the SNS topic to subscribe to.
- `email_addresses` (list(string), optional): List of email addresses to subscribe.
- `tags` (map(string), optional): Tags to apply to resources.

## Outputs

- `subscription_arns`: ARNs of the created SNS subscriptions.
- `subscription_endpoints`: Email endpoints that were subscribed.

## Example Usage

```hcl
module "sns_subscriptions" {
  source = "../terraform/monitoring/sns_subscriptions"
  
  sns_topic_arn = module.ecs_service_alarms.sns_topic_arn
  email_addresses = [
    "admin@example.com",
    "devops@example.com"
  ]
  tags = var.tags
}
```

## Notes

- Email subscriptions require manual confirmation via email.
- Check your email inbox for confirmation links after applying. 