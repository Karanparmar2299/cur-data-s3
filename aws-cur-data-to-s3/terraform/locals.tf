locals {
  schedule_expression = lookup({
    daily   = "cron(0 12 * * ? *)",
    weekly  = "cron(0 12 ? * TUE *)",
    monthly = "cron(0 12 2 * ? *)"
  }, var.CUR_RANGE, "cron(0 12 * * ? *)")
}