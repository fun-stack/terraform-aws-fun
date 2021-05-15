resource "aws_budgets_budget" "budget" {
  count = var.budget == null ? 0 : 1

  name              = "${local.prefix}-budget-monthly"
  budget_type       = "COST"
  limit_amount      = var.budget.limit_dollar
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = "2021-01-01_00:00"

  cost_filters = {
    TagKeyValue = join("", ["user:funstack$", local.prefix])
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.budget.notify_email]
  }
}
