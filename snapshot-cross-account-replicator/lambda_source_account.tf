## Create snapshots lambda

resource "aws_lambda_function" "rds_create_snapshots" {
  provider         = aws.source
  function_name    = "rds-create-snapshots-${var.name}"
  role             = aws_iam_role.lambda.arn
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

resource "aws_cloudwatch_event_rule" "invoke_rds_create_snapshots_lambda" {
  provider            = aws.source
  description         = "Triggers the lambda function ${aws_lambda_function.rds_create_snapshots.function_name}"
  schedule_expression = var.snapshot_schedule_expression
}

resource "aws_cloudwatch_event_target" "invoke_rds_create_snapshots_lambda" {
  provider = aws.source
  rule     = aws_cloudwatch_event_rule.invoke_rds_create_snapshots_lambda.name
  arn      = aws_lambda_function.rds_create_snapshots.arn
}

resource "aws_lambda_permission" "invoke_rds_create_snapshots_lambda" {
  provider      = aws.source
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_create_snapshots.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.invoke_rds_create_snapshots_lambda.arn
}

## Replicate cross-region snapshot lambda

resource "aws_lambda_function" "rds_replicate_cross_region_snapshot" {
  provider         = aws.source
  function_name    = "rds-replicate-region-snapshot-${var.name}"
  role             = aws_iam_role.lambda.arn
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
#### replicate_snapshot Lambda function
resource "aws_cloudwatch_event_rule" "invoke_rds_replicate_cross_region_snapshot_lambda" {
  provider      = aws.source
  description   = "Triggers lambda function ${aws_lambda_function.rds_replicate_cross_region_snapshot.function_name}"
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

resource "aws_cloudwatch_event_target" "invoke_rds_replicate_cross_region_snapshot_lambda" {
  provider = aws.source
  rule     = aws_cloudwatch_event_rule.invoke_rds_replicate_cross_region_snapshot_lambda.name
  arn      = aws_lambda_function.rds_replicate_cross_region_snapshot.arn
}

resource "aws_lambda_permission" "invoke_rds_replicate_cross_region_snapshot_lambda" {
  provider      = aws.source
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_replicate_cross_region_snapshot.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.invoke_rds_replicate_cross_region_snapshot_lambda.arn
}

## Replicate cross-account snapshot lambda

resource "aws_lambda_function" "rds_replicate_cross_account_snapshot" {
  provider         = aws.intermediate
  function_name    = "rds-replicate-account-snapshot-${var.name}"
  role             = aws_iam_role.lambda.arn
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
resource "aws_cloudwatch_event_rule" "invoke_rds_replicate_cross_account_snapshot_lambda" {
  provider      = aws.intermediate
  description   = "Triggers lambda function ${aws_lambda_function.rds_replicate_cross_account_snapshot.function_name}"
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

resource "aws_cloudwatch_event_target" "invoke_rds_replicate_cross_account_snapshot_lambda" {
  provider = aws.intermediate
  rule     = aws_cloudwatch_event_rule.invoke_rds_replicate_cross_account_snapshot_lambda.name
  arn      = aws_lambda_function.rds_replicate_cross_account_snapshot.arn
}

resource "aws_lambda_permission" "invoke_rds_replicate_cross_account_snapshot_lambda" {
  provider      = aws.intermediate
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_replicate_cross_account_snapshot.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.invoke_rds_replicate_cross_account_snapshot_lambda.arn
}
