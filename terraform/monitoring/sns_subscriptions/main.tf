resource "aws_sns_topic_subscription" "email_subscriptions" {
  for_each = toset(var.email_addresses)
  
  topic_arn = var.sns_topic_arn
  protocol  = "email"
  endpoint  = each.value
} 