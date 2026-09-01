locals {
  name_suffix = var.environment != "" ? "-${var.environment}" : ""
}

resource "aws_sns_topic" "budget" {
  name = "budget-alerts${local.name_suffix}"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.budget.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

resource "aws_sns_topic_policy" "budget" {
  arn = aws_sns_topic.budget.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowBudgetPublish"
        Effect    = "Allow"
        Principal = { Service = "budgets.amazonaws.com" }
        Action    = "SNS:Publish"
        Resource  = aws_sns_topic.budget.arn
      }
    ]
  })
}

resource "aws_budgets_budget" "monthly" {
  name         = "monthly-account-budget${local.name_suffix}"
  budget_type  = "COST"
  limit_amount = var.limit_amount
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  dynamic "notification" {
    for_each = var.thresholds
    content {
      comparison_operator        = "GREATER_THAN"
      threshold                  = notification.value
      threshold_type             = "PERCENTAGE"
      notification_type          = "ACTUAL"
      subscriber_sns_topic_arns  = [aws_sns_topic.budget.arn]
    }
  }
}
