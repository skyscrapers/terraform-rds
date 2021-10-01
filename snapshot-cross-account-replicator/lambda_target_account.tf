## Delete intermediate snapshot lambda

resource "aws_lambda_function" "rds_delete_intermediate_snapshot" {
  provider         = aws.target
  function_name    = "rds-delete-intermediate-snapshot-${var.name}"
  role             = aws_iam_role.target_lambda.arn
  handler          = "lambda.delete_intermediate_snapshot"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.8"
  timeout          = "120"

  environment {
    variables = local.lambda_default_environment_variables
  }

  lifecycle {
    ignore_changes = [
      filename
    ]
  }
}

## This event will be triggered when the final snapshot has been copied to the target account
## so the intermediate snapshot can be safely deleted
resource "aws_cloudwatch_event_rule" "invoke_rds_delete_intermediate_snapshot_lambda" {
  provider      = aws.target
  description   = "Triggers lambda function ${aws_lambda_function.rds_delete_intermediate_snapshot.function_name}"
  event_pattern = <<EOF
{
  "source": ["aws.rds"],
  "detail-type": ["RDS DB Snapshot Event"],
  "region": ["${data.aws_region.intermediate.name}"],
  "detail": {
    "SourceIdentifier": ${jsonencode(local.event_rule_pattern)},
    "Message": [{"prefix": "Finished copy of snapshot "}],
    "EventCategories": ["notification"],
    "SourceType": ["SNAPSHOT"],
    "EventID": ["RDS-EVENT-0197"]
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "invoke_rds_delete_intermediate_snapshot_lambda" {
  provider = aws.target
  rule     = aws_cloudwatch_event_rule.invoke_rds_delete_intermediate_snapshot_lambda.name
  arn      = aws_lambda_function.rds_delete_intermediate_snapshot.arn
}

resource "aws_lambda_permission" "invoke_rds_delete_intermediate_snapshot_lambda" {
  provider      = aws.target
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_delete_intermediate_snapshot.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.invoke_rds_delete_intermediate_snapshot_lambda.arn
}

## Cleanup final snapshots lambda

resource "aws_lambda_function" "rds_cleanup_snapshots" {
  provider         = aws.target
  function_name    = "rds-cleanup-snapshots-${var.name}"
  role             = aws_iam_role.target_lambda.arn
  handler          = "lambda.cleanup_snapshots"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.8"
  timeout          = "120"

  environment {
    variables = local.lambda_default_environment_variables
  }

  lifecycle {
    ignore_changes = [
      filename
    ]
  }
}

resource "aws_cloudwatch_event_rule" "invoke_rds_cleanup_snapshots_lambda" {
  provider            = aws.target
  description         = "Triggers lambda function ${aws_lambda_function.rds_cleanup_snapshots.function_name}"
  schedule_expression = "cron(0 3 * * ? *)"
}

resource "aws_cloudwatch_event_target" "invoke_rds_cleanup_snapshots_lambda" {
  provider = aws.target
  rule     = aws_cloudwatch_event_rule.invoke_rds_cleanup_snapshots_lambda.name
  arn      = aws_lambda_function.rds_cleanup_snapshots.arn
}

resource "aws_lambda_permission" "invoke_rds_cleanup_snapshots_lambda" {
  provider      = aws.target
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_cleanup_snapshots.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.invoke_rds_cleanup_snapshots_lambda.arn
}
