resource "aws_cloudwatch_event_rule" "cur_event_bridge_rule" {
  name                = "cost-report-${var.CUR_RANGE}"
  schedule_expression = local.schedule_expression
}

resource "aws_cloudwatch_event_target" "cost_report_target" {
  rule      = aws_cloudwatch_event_rule.cur_event_bridge_rule.name
  target_id = "invoke-lambda"
  arn       = aws_lambda_function.cur_lambda.arn

  input = jsonencode({
    CUR_RANGE = var.CUR_RANGE
  })
}

resource "aws_lambda_permission" "cur_allow_eventbridge" {
  statement_id  = "AllowCURLambdaExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cur_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cur_event_bridge_rule.arn
}