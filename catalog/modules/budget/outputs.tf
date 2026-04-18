output "budget_name" {
  description = "Name of the budget"
  value       = aws_budgets_budget.monthly.name
}

output "sns_topic_arn" {
  description = "ARN of the budget notification SNS topic"
  value       = aws_sns_topic.budget.arn
}
