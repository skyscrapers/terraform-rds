## Step 1 Lambda function:
##  will create the initial snapshots in the source account & source region

resource "aws_lambda_function" "step_1" {
  provider         = aws.source
  function_name    = "rds-snapshots-replicator-step-1-${var.name}"
  role             = aws_iam_role.source_lambda.arn
  handler          = "lambda.create_snapshots"
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

resource "aws_cloudwatch_event_rule" "invoke_step_1_lambda" {
  provider            = aws.source
  description         = "Triggers the lambda function ${aws_lambda_function.step_1.function_name}"
  schedule_expression = var.snapshot_schedule_expression
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
  function_name    = "rds-snapshots-replicator-step-2-${var.name}"
  role             = aws_iam_role.source_lambda.arn
  handler          = "lambda.replicate_snapshot"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.8"
  timeout          = "120"

  environment {
    variables = merge(local.lambda_default_environment_variables, {
      TYPE = "cross-region"
    })
  }

  lifecycle {
    ignore_changes = [
      filename
    ]
  }
}

#### This EventBridge event rule filters RDS snapshot creation events
#### relevant to the configured RDS instances only, and triggers the
#### step 2 Lambda function
resource "aws_cloudwatch_event_rule" "invoke_step_2_lambda" {
  provider      = aws.source
  description   = "Triggers lambda function ${aws_lambda_function.step_2.function_name}"
  event_pattern = <<EOF
{
  "source": ["aws.rds"],
  "detail-type": ["RDS DB Snapshot Event"],
  "region": ["${data.aws_region.source.name}"],
  "detail": {
    "SourceIdentifier": ${jsonencode(local.event_rule_pattern)},
    "Message": ["Manual snapshot created"],
    "EventCategories": ["creation"],
    "SourceType": ["SNAPSHOT"]
  }
}
EOF
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
##  Will also delete the initial snapshot created in step 1.

resource "aws_lambda_function" "step_3" {
  provider         = aws.intermediate
  function_name    = "rds-snapshots-replicator-step-3-${var.name}"
  role             = aws_iam_role.source_lambda.arn
  handler          = "lambda.replicate_snapshot"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.8"
  timeout          = "120"

  environment {
    variables = merge(local.lambda_default_environment_variables, {
      TYPE = "cross-account"
    })
  }

  lifecycle {
    ignore_changes = [
      filename
    ]
  }
}

#### This EventBridge event rule filters RDS snapshot copy events
#### relevant to the configured RDS instances only
resource "aws_cloudwatch_event_rule" "invoke_step_3_lambda" {
  provider      = aws.intermediate
  description   = "Triggers lambda function ${aws_lambda_function.step_3.function_name}"
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
    "EventID": ["RDS-EVENT-0060"]
  }
}
EOF
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