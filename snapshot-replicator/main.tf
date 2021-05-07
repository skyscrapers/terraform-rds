#KMS key for secure copy of RDS snapshots
resource "aws_kms_key" "dr_key" {
  count                   = var.enable ? 1 : 0
  provider                = aws.replica
  description             = "DR RDS KEY"
  deletion_window_in_days = 10
}


provider "aws" {
  alias = "replica"
}

#Multiple IAM policies to allow the execution of lambda scripts
resource "aws_iam_role" "iam_for_lambda" {
  count = var.enable ? 1 : 0
  name  = "rds_snapshot_lambda_${var.environment}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF

}

resource "aws_iam_policy" "rds_snapshot_copy" {
  count = var.enable ? 1 : 0
  name  = "rds-lambda-copy-${var.environment}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "rds:CopyDBSnapshot",
      "rds:DeleteDBSnapshot",
      "rds:Describe*",
      "kms:CreateGrant",
      "kms:DescribeKey"
    ],
    "Resource": "*"
  }]
}
EOF

}

resource "aws_iam_role_policy_attachment" "attach_lambda_copy_policy_to_role" {
  count      = var.enable ? 1 : 0
  role       = aws_iam_role.iam_for_lambda[0].name
  policy_arn = aws_iam_policy.rds_snapshot_copy[0].arn
}

resource "aws_iam_role_policy_attachment" "lambda_exec_role" {
  count      = var.enable ? 1 : 0
  role       = aws_iam_role.iam_for_lambda[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "rds_lambda_create_snapshot" {
  count = var.enable ? 1 : 0
  name  = "rds-lambda-create-snapshot-${var.environment}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "rds:CreateDBSnapshot"
    ],
    "Resource": "*"
  }]
}
EOF

}

resource "aws_iam_role_policy_attachment" "attach_lambda_create_policy_to_role" {
  count      = var.enable ? 1 : 0
  role       = aws_iam_role.iam_for_lambda[0].name
  policy_arn = aws_iam_policy.rds_lambda_create_snapshot[0].arn
}

resource "aws_iam_role" "states_execution_role" {
  count = var.enable ? 1 : 0
  name  = "states-execution-role-${var.environment}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "states.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_policy" "states_execution_policy" {
  count = var.enable ? 1 : 0
  name  = "states-execution-policy-${var.environment}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeFunction"
            ],
            "Resource": "*"
        }
    ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "attach_states_policy_to_role" {
  count      = var.enable ? 1 : 0
  role       = aws_iam_role.states_execution_role[0].name
  policy_arn = aws_iam_policy.states_execution_policy[0].arn
}

#Create zip file with all lambda code
data "archive_file" "create_zip" {
  type        = "zip"
  output_path = "${path.module}/shipper.zip"

  source_dir = "${path.module}/functions/"
}


#Creation of lambda function to copy snapshots to remote region
resource "aws_lambda_function" "rds_snapshot_copy" {
  count         = var.enable ? 1 : 0
  function_name = "rds-copy-snapshot-${var.environment}"
  role          = aws_iam_role.iam_for_lambda[0].arn
  handler       = "shipper.lambda_handler"

  filename         = data.archive_file.create_zip.output_path
  source_code_hash = data.archive_file.create_zip.output_base64sha256

  runtime = "python3.8"
  timeout = "120"

  environment {
    variables = {
      SOURCE_REGION = var.aws_source_region
      TARGET_REGION = var.aws_destination_region
      DB_INSTANCES  = join(",", var.db_instances)
      KMS_KEY_ID    = aws_kms_key.dr_key[0].arn
    }
  }
}

#Creation of lambda function to create snapshots

resource "aws_lambda_function" "rds_snapshot_create" {
  count         = var.enable ? 1 : 0
  function_name = "rds-create-snapshot-${var.environment}"
  role          = aws_iam_role.iam_for_lambda[0].arn
  handler       = "create_snapshot.lambda_handler"

  filename         = data.archive_file.create_zip.output_path
  source_code_hash = data.archive_file.create_zip.output_base64sha256

  runtime = "python3.8"
  timeout = "120"

  environment {
    variables = {
      SOURCE_REGION = var.aws_source_region
      DB_INSTANCES  = join(",", var.db_instances)
    }
  }
}

#Creation of lambda function to remove snapshots in remote region

resource "aws_lambda_function" "rds_snapshot_cleanup" {
  count         = var.enable ? 1 : 0
  function_name = "remove-snapshot-retention-${var.environment}"
  role          = aws_iam_role.iam_for_lambda[0].arn
  handler       = "remove_snapshots.lambda_handler"

  filename         = data.archive_file.create_zip.output_path
  source_code_hash = data.archive_file.create_zip.output_base64sha256

  runtime = "python3.8"
  timeout = "120"

  environment {
    variables = {
      SOURCE_REGION = var.aws_source_region
      TARGET_REGION = var.aws_destination_region
      DB_INSTANCES  = join(",", var.db_instances)
      RETENTION     = var.retention
    }
  }
}

#Creation of SNS topic for RDS backup events
resource "aws_sns_topic" "rds_backup_events" {
  count = var.enable ? 1 : 0
  name  = "rds-backup-events-${var.environment}"
}

#Creation of RDS event subscription to notify the SNS topic a backup has been created
#The name value does not support underscores
resource "aws_db_event_subscription" "default" {
  count     = var.enable ? 1 : 0
  name      = "rds-manual-snapshot-${var.environment}"
  sns_topic = aws_sns_topic.rds_backup_events[0].arn

  source_type = "db-snapshot"

  event_categories = [
    "creation",
  ]
}

#Linking the topic to trigger a lambda function
resource "aws_sns_topic_subscription" "lambda_subscription" {
  count     = var.enable ? 1 : 0
  topic_arn = aws_sns_topic.rds_backup_events[0].arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.rds_snapshot_copy[0].arn
}

#Creation of permissions to allow sns to trigger lambda function
resource "aws_lambda_permission" "with_sns" {
  count         = var.enable ? 1 : 0
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_snapshot_copy[0].arn
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.rds_backup_events[0].arn
}

#Creation of cronjobs
#Job for triggering backups
resource "aws_cloudwatch_event_rule" "invoke_rds_snapshot_lambda" {
  count               = var.enable ? 1 : 0
  name                = "invokes-rds-snapshot-lambda-${var.environment}"
  description         = "Fires every 6 hours"
  schedule_expression = "rate(${var.custom_snapshot_rate} hours)"
}

#Job for cleaning up old retention
resource "aws_cloudwatch_event_rule" "invoke_rds_cleanup_lambda" {
  count               = var.enable ? 1 : 0
  name                = "invoke-rds-cleanup-lambda-${var.environment}"
  description         = "Fires every 24 hours"
  schedule_expression = "rate(24 hours)"
}

resource "aws_cloudwatch_event_target" "activate_lambda_cron" {
  count     = var.enable ? 1 : 0
  rule      = aws_cloudwatch_event_rule.invoke_rds_snapshot_lambda[0].name
  target_id = "rds-backup"
  arn       = aws_lambda_function.rds_snapshot_create[0].arn
}

resource "aws_cloudwatch_event_target" "activate_lambda_removal_cron" {
  count     = var.enable ? 1 : 0
  rule      = aws_cloudwatch_event_rule.invoke_rds_cleanup_lambda[0].name
  target_id = "rds-retention-removal"
  arn       = aws_lambda_function.rds_snapshot_cleanup[0].arn
}


resource "aws_lambda_permission" "cloudwatch_invoke_rds_snapshot_lambda" {
  count         = var.enable ? 1 : 0
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_snapshot_create[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.invoke_rds_snapshot_lambda[0].arn
}

resource "aws_lambda_permission" "cloudwatch_invoke_rds_cleanup_lambda" {
  count         = var.enable ? 1 : 0
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_snapshot_cleanup[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.invoke_rds_cleanup_lambda[0].arn
}
