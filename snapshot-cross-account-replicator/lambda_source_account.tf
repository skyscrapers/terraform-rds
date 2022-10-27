## Step 1 Lambda function:
##  will create the initial snapshots in the source account & source region

resource "aws_lambda_function" "step_1" {
  provider         = aws.source
  function_name    = "rds-snapshots-repl-step-1-${var.name}"
  role             = aws_iam_role.source_lambda.arn
  handler          = "lambda.create_snapshots"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.9"
  architectures    = ["arm64"]
  timeout          = "120"

  environment {
    variables = local.lambda_default_environment_variables
  }
}

resource "aws_cloudwatch_event_rule" "invoke_step_1_lambda" {
  provider            = aws.source
  description         = "Triggers the lambda function ${aws_lambda_function.step_1.function_name}"
  schedule_expression = "rate(${var.snapshot_schedule_period} hours)"
}

resource "aws_cloudwatch_event_target" "invoke_step_1_lambda" {
  provider = aws.source
  rule     = aws_cloudwatch_event_rule.invoke_step_1_lambda.name
  arn      = aws_lambda_function.step_1.arn
}

resource "aws_lambda_permission" "invoke_step_1_lambda" {
  provider      = aws.source
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.step_1.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.invoke_step_1_lambda.arn
}

## Step 2 Lambda function:
##  Copies the initial snapshot to the replica region within the source account

resource "aws_lambda_function" "step_2" {
  provider         = aws.source
  function_name    = "rds-snapshots-repl-step-2-${var.name}"
  role             = aws_iam_role.source_lambda.arn
  handler          = "lambda.replicate_snapshot"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.9"
  architectures    = ["arm64"]
  timeout          = "120"

  environment {
    variables = merge(local.lambda_default_environment_variables, {
      TYPE = "cross-region"
    })
  }
}

#### This EventBridge event rule filters RDS snapshot creation events
#### relevant to the configured RDS instances only, and triggers the
#### step 2 Lambda function
resource "aws_cloudwatch_event_rule" "invoke_step_2_lambda" {
  provider      = aws.source
  description   = "Triggers lambda function ${aws_lambda_function.step_2.function_name}"
  event_pattern = var.is_aurora_cluster ? local.invoke_step_2_lambda_event_pattern_cluster : local.invoke_step_2_lambda_event_pattern_instance
}

resource "aws_cloudwatch_event_target" "invoke_step_2_lambda" {
  provider = aws.source
  rule     = aws_cloudwatch_event_rule.invoke_step_2_lambda.name
  arn      = aws_lambda_function.step_2.arn
}

resource "aws_lambda_permission" "invoke_step_2_lambda" {
  provider      = aws.source
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.step_2.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.invoke_step_2_lambda.arn
}

## Step 3 Lambda function:
##  Copies the snapshot created in step 2 to the replica AWS account.

resource "aws_lambda_function" "step_3" {
  provider         = aws.intermediate
  function_name    = "rds-snapshots-repl-step-3-${var.name}"
  role             = aws_iam_role.source_lambda.arn
  handler          = "lambda.replicate_snapshot"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.9"
  architectures    = ["arm64"]
  timeout          = "120"

  environment {
    variables = merge(local.lambda_default_environment_variables, {
      TYPE = "cross-account"
    })
  }
}

#### This EventBridge event rule either filters RDS snapshot copy events
#### relevant to the configured RDS instances only (for instances)
#### OR in case of cluster trigger on a CRON schedule evry 30 min
resource "aws_cloudwatch_event_rule" "invoke_step_3_lambda" {
  provider            = aws.intermediate
  description         = "Triggers lambda function ${aws_lambda_function.step_3.function_name}"
  event_pattern       = !var.is_aurora_cluster ? local.invoke_step_3_lambda_event_pattern_instance : null
  schedule_expression = var.is_aurora_cluster ? "cron(*/30 * * * ? *)" : null
}

resource "aws_cloudwatch_event_target" "invoke_step_3_lambda" {
  provider = aws.intermediate
  rule     = aws_cloudwatch_event_rule.invoke_step_3_lambda.name
  arn      = aws_lambda_function.step_3.arn
}

resource "aws_lambda_permission" "invoke_step_3_lambda" {
  provider      = aws.intermediate
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.step_3.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.invoke_step_3_lambda.arn
}

## Cleanup source Lambda function:
##  Runs periodically to delete old snapshots from the source account (source region),
##  based on the configured retention period.

resource "aws_lambda_function" "cleanup_source" {
  provider         = aws.source
  function_name    = "rds-snapshots-repl-cleanup-source-${var.name}"
  role             = aws_iam_role.source_lambda.arn
  handler          = "lambda.cleanup_intermediate_snapshots"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.9"
  architectures    = ["arm64"]
  timeout          = "120"

  environment {
    variables = local.lambda_default_environment_variables
  }
}

resource "aws_cloudwatch_event_rule" "invoke_cleanup_source_lambda" {
  provider            = aws.source
  description         = "Triggers lambda function ${aws_lambda_function.cleanup_source.function_name}"
  schedule_expression = "cron(0 3 * * ? *)"
}

resource "aws_cloudwatch_event_target" "invoke_cleanup_source_lambda" {
  provider = aws.source
  rule     = aws_cloudwatch_event_rule.invoke_cleanup_source_lambda.name
  arn      = aws_lambda_function.cleanup_source.arn
}

resource "aws_lambda_permission" "invoke_cleanup_source_lambda" {
  provider      = aws.source
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cleanup_source.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.invoke_cleanup_source_lambda.arn
}

## Cleanup intermediate Lambda function:
##  Runs periodically to delete old snapshots from the source account (target region),
##  based on the configured retention period.

resource "aws_lambda_function" "cleanup_intermediate" {
  provider         = aws.intermediate
  function_name    = "rds-snapshots-repl-cleanup-int-${var.name}"
  role             = aws_iam_role.source_lambda.arn
  handler          = "lambda.cleanup_intermediate_snapshots"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.9"
  architectures    = ["arm64"]
  timeout          = "120"

  environment {
    variables = local.lambda_default_environment_variables
  }
}

resource "aws_cloudwatch_event_rule" "invoke_cleanup_intermediate_lambda" {
  provider            = aws.intermediate
  description         = "Triggers lambda function ${aws_lambda_function.cleanup_intermediate.function_name}"
  schedule_expression = "cron(0 3 * * ? *)"
}

resource "aws_cloudwatch_event_target" "invoke_cleanup_intermediate_lambda" {
  provider = aws.intermediate
  rule     = aws_cloudwatch_event_rule.invoke_cleanup_intermediate_lambda.name
  arn      = aws_lambda_function.cleanup_intermediate.arn
}

resource "aws_lambda_permission" "invoke_cleanup_intermediate_lambda" {
  provider      = aws.intermediate
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cleanup_intermediate.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.invoke_cleanup_intermediate_lambda.arn
}
