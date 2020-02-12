locals {
  cw_alarm_custom_period = 3600 * var.custom_snapshot_rate
  cw_alarm_daily_period  = 3600 * 24
}

resource "aws_cloudwatch_metric_alarm" "lambda_rds_snapshot_copy_errors" {
  count               = var.enable ? 1 : 0
  alarm_name          = "rds_snapshot_copy_${var.environment}_errors"
  alarm_description   = "The errors on rds_snapshot_copy are higher than 1"
  namespace           = "AWS/Lambda"
  metric_name         = "Errors"
  statistic           = "Sum"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 1
  evaluation_periods  = 1
  period              = local.cw_alarm_custom_period

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  dimensions = {
    FunctionName = aws_lambda_function.rds_snapshot_copy[0].function_name
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_rds_snapshot_create_errors" {
  count               = var.enable ? 1 : 0
  alarm_name          = "rds_snapshot_create_${var.environment}_errors"
  alarm_description   = "The errors on rds_snapshot_create are higher than 1"
  namespace           = "AWS/Lambda"
  metric_name         = "Errors"
  statistic           = "Sum"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 1
  evaluation_periods  = 1
  period              = local.cw_alarm_custom_period

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  dimensions = {
    FunctionName = aws_lambda_function.rds_snapshot_create[0].function_name
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_rds_snapshot_cleanup_errors" {
  count               = var.enable ? 1 : 0
  alarm_name          = "rds_snapshot_cleanup_invocation_${var.environment}_errors"
  alarm_description   = "The errors on rds_snapshot_cleanup are higher than 1"
  namespace           = "AWS/Lambda"
  metric_name         = "Errors"
  statistic           = "Sum"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 1
  evaluation_periods  = 1
  period              = local.cw_alarm_daily_period

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  dimensions = {
    FunctionName = aws_lambda_function.rds_snapshot_cleanup[0].function_name
  }
}

resource "aws_cloudwatch_metric_alarm" "invoke_rds_snapshot_lambda" {
  count               = var.enable ? 1 : 0
  alarm_name          = "rds-snapshot-lambda-${var.environment}-failed-invocations"
  alarm_description   = "Failed invocations for rds-snapshot-lambda"
  namespace           = "AWS/Events"
  metric_name         = "FailedInvocations"
  statistic           = "Sum"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 1
  evaluation_periods  = 1
  period              = local.cw_alarm_custom_period

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  dimensions = {
    RuleName = "invoke-rds-snapshot-lambda-${var.environment}"
  }
}

resource "aws_cloudwatch_metric_alarm" "invoke_rds_cleanup_lambda" {
  count               = var.enable ? 1 : 0
  alarm_name          = "rds-cleanup-lambda-${var.environment}-failed-invocations"
  alarm_description   = "Failed invocations for rds-cleanup-lambda"
  namespace           = "AWS/Events"
  metric_name         = "FailedInvocations"
  statistic           = "Sum"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 1
  evaluation_periods  = 1
  period              = local.cw_alarm_daily_period

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  dimensions = {
    RuleName = "invoke-rds-cleanup-lambda-${var.environment}"
  }
}

