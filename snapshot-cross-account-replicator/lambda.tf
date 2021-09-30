locals {
  event_rule_pattern = [for rds in data.aws_db_instance.rds : {
    prefix = "${rds.db_instance_identifier}-"
  }]
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda.zip"
  source_dir  = "${path.module}/functions/"
}

## Create snapshots lambda

resource "aws_lambda_function" "rds_create_snapshots" {
  provider         = aws.source
  function_name    = "rds-create-snapshots-${var.name}"
  role             = aws_iam_role.lambda.arn
  handler          = "create_snapshots.lambda_handler"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.8"
  timeout          = "120"

  environment {
    variables = {
      RDS_INSTANCE_IDS = join(",", var.rds_instance_ids)
      SETUP_NAME       = local.setup_name
    }
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

## Cleanup snapshots lambda

resource "aws_lambda_function" "rds_cleanup_snapshots" {
  provider         = aws.source
  function_name    = "rds-cleanup-snapshots-${var.name}"
  role             = aws_iam_role.lambda.arn
  handler          = "cleanup_snapshots.lambda_handler"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.8"
  timeout          = "120"

  environment {
    variables = {
      RDS_INSTANCE_IDS = join(",", var.rds_instance_ids)
      RETENTION_PERIOD = var.retention_period
      SETUP_NAME       = local.setup_name
    }
  }

  lifecycle {
    ignore_changes = [
      filename
    ]
  }
}

resource "aws_cloudwatch_event_rule" "invoke_rds_cleanup_snapshots_lambda" {
  provider            = aws.source
  description         = "Triggers lambda function ${aws_lambda_function.rds_cleanup_snapshots.function_name}"
  schedule_expression = "cron(0 3 * * ? *)"
}

resource "aws_cloudwatch_event_target" "invoke_rds_cleanup_snapshots_lambda" {
  provider = aws.source
  rule     = aws_cloudwatch_event_rule.invoke_rds_cleanup_snapshots_lambda.name
  arn      = aws_lambda_function.rds_cleanup_snapshots.arn
}

resource "aws_lambda_permission" "invoke_rds_cleanup_snapshots_lambda" {
  provider      = aws.source
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_cleanup_snapshots.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.invoke_rds_cleanup_snapshots_lambda.arn
}

## Replicate cross-region snapshot lambda

resource "aws_lambda_function" "rds_replicate_cross_region_snapshot" {
  provider         = aws.source
  function_name    = "rds-replicate-region-snapshot-${var.name}"
  role             = aws_iam_role.lambda.arn
  handler          = "replicate_snapshot.lambda_handler"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.8"
  timeout          = "120"

  environment {
    variables = {
      RDS_INSTANCE_IDS           = join(",", var.rds_instance_ids)
      SETUP_NAME                 = local.setup_name
      TARGET_ACCOUNT_IAM_ROLE    = ""
      TARGET_REGION              = data.aws_region.intermediate.name
      TARGET_ACCOUNT_KMS_KEY_ARN = data.aws_kms_key.target_key.arn
      TARGET_ACCOUNT_ID          = ""
      TYPE                       = "cross-region"
      SOURCE_REGION              = data.aws_region.source.name
    }
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
  handler          = "replicate_snapshot.lambda_handler"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.8"
  timeout          = "120"

  environment {
    variables = {
      RDS_INSTANCE_IDS           = join(",", var.rds_instance_ids)
      SETUP_NAME                 = local.setup_name
      TARGET_ACCOUNT_IAM_ROLE    = aws_iam_role.target_lambda.arn
      TARGET_REGION              = data.aws_region.target.name
      TARGET_ACCOUNT_KMS_KEY_ARN = data.aws_kms_key.target_key.arn
      TARGET_ACCOUNT_ID          = data.aws_caller_identity.target.account_id
      TYPE                       = "cross-account"
      SOURCE_REGION              = data.aws_region.intermediate.name
    }
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
