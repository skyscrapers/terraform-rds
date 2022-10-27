## Cleanup target account Lambda function:
##  Runs periodically to delete old snapshots from the replica account,
##  based on the configured retention period.

resource "aws_lambda_function" "cleanup_target" {
  provider         = aws.target
  function_name    = "rds-snapshots-repl-cleanup-target-${var.name}"
  role             = aws_iam_role.target_lambda.arn
  handler          = "lambda.cleanup_final_snapshots"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.9"
  architectures    = ["arm64"]
  timeout          = "120"

  environment {
    variables = local.lambda_default_environment_variables
  }
}

resource "aws_cloudwatch_event_rule" "invoke_cleanup_target_lambda" {
  provider            = aws.target
  description         = "Triggers lambda function ${aws_lambda_function.cleanup_target.function_name}"
  schedule_expression = "cron(0 3 * * ? *)"
}

resource "aws_cloudwatch_event_target" "invoke_cleanup_target_lambda" {
  provider = aws.target
  rule     = aws_cloudwatch_event_rule.invoke_cleanup_target_lambda.name
  arn      = aws_lambda_function.cleanup_target.arn
}

resource "aws_lambda_permission" "invoke_cleanup_target_lambda" {
  provider      = aws.target
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cleanup_target.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.invoke_cleanup_target_lambda.arn
}
