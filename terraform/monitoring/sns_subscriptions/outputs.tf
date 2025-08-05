output "subscription_arns" {
  description = "ARNs of the created SNS subscriptions"
  value       = [for subscription in aws_sns_topic_subscription.email_subscriptions : subscription.arn]
}

output "subscription_endpoints" {
  description = "Email endpoints that were subscribed"
  value       = var.email_addresses
} 