## Step 4 Lambda function:
##  Triggered when the final snapshot in the replica AWS account has finished copying,
##  this function will delete the intermediate snapshot created in step 2.

resource "aws_lambda_function" "step_4" {
  provider         = aws.target
  function_name    = "rds-snapshots-replicator-step-4-${var.name}"
  role             = aws_iam_role.target_lambda.arn
  handler          = "lambda.delete_intermediate_snapshot"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.9"
  architectures    = ["arm64"]
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
resource "aws_cloudwatch_event_rule" "invoke_step_4_lambda" {
  provider            = aws.target
  description         = "Triggers lambda function ${aws_lambda_function.step_4.function_name}"
  event_pattern       = !var.is_aurora_cluster ? local.invoke_step_4_lambda_event_pattern_instance : null
  schedule_expression = var.is_aurora_cluster ? "cron(*/30 * * * ? *)" : null
}

resource "aws_cloudwatch_event_target" "invoke_step_4_lambda" {
  provider = aws.target
  rule     = aws_cloudwatch_event_rule.invoke_step_4_lambda.name
  arn      = aws_lambda_function.step_4.arn
}

resource "aws_lambda_permission" "invoke_step_4_lambda" {
  provider      = aws.target
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.step_4.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.invoke_step_4_lambda.arn
}

## Cleanup Lambda function:
##  Runs periodically to delete old snapshots from the replica account,
##  based on the configured retention period.

resource "aws_lambda_function" "cleanup_snapshots" {
  provider         = aws.target
  function_name    = "rds-snapshots-replicator-cleanup-${var.name}"
  role             = aws_iam_role.target_lambda.arn
  handler          = "lambda.cleanup_snapshots"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.9"
  architectures    = ["arm64"]
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

resource "aws_cloudwatch_event_rule" "invoke_cleanup_snapshots_lambda" {
  provider            = aws.target
  description         = "Triggers lambda function ${aws_lambda_function.cleanup_snapshots.function_name}"
  schedule_expression = "cron(0 3 * * ? *)"
}

resource "aws_cloudwatch_event_target" "invoke_cleanup_snapshots_lambda" {
  provider = aws.target
  rule     = aws_cloudwatch_event_rule.invoke_cleanup_snapshots_lambda.name
  arn      = aws_lambda_function.cleanup_snapshots.arn
}

resource "aws_lambda_permission" "invoke_cleanup_snapshots_lambda" {
  provider      = aws.target
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cleanup_snapshots.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.invoke_cleanup_snapshots_lambda.arn
}
