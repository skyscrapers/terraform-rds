#KMS key for secure copy of RDS snapshots
resource "aws_kms_key" "dr_key" {
  count                   = "${var.enable ? 1 : 0}"
  provider                = "aws.replica"
  description             = "DR RDS KEY"
  deletion_window_in_days = 10
}

#Multiple IAM policies to allow the execution of lambda scripts
resource "aws_iam_role" "iam_for_lambda" {
  count = "${var.enable ? 1 : 0}"
  name  = "default_lambda"

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

resource "aws_iam_policy" "rds_lambda_copy" {
  count = "${var.enable ? 1 : 0}"
  name  = "rds_lambda_copy"

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
  count      = "${var.enable ? 1 : 0}"
  role       = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "${aws_iam_policy.rds_lambda_copy.arn}"
}

resource "aws_iam_policy" "rds_lambda_create_snapshot" {
  count = "${var.enable ? 1 : 0}"
  name  = "rds_lambda_create_snapshot"

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
  count      = "${var.enable ? 1 : 0}"
  role       = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "${aws_iam_policy.rds_lambda_create_snapshot.arn}"
}

resource "aws_iam_role" "states_execution_role" {
  count = "${var.enable ? 1 : 0}"
  name  = "states_execution_role"

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
  count = "${var.enable ? 1 : 0}"
  name  = "states_execution_policy"

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
  count      = "${var.enable ? 1 : 0}"
  role       = "${aws_iam_role.states_execution_role.name}"
  policy_arn = "${aws_iam_policy.states_execution_policy.arn}"
}

#Create zip file with all lambda code
data "archive_file" "create_zip" {
  type        = "zip"
  output_path = "${path.module}/shipper.zip"

  source_dir = "${path.module}/functions/"
}

locals {
  count = "${var.enable ? 1 : 0}"

  # Solution from this comment to open issue on non-relative paths  # https://github.com/hashicorp/terraform/issues/8204#issuecomment-332239294

  filename = "${substr(data.archive_file.create_zip.output_path, length(path.cwd) + 1, -1)}"

  // +1 for removing the "/"
}

#Creation of lambda function to copy snapshots to remote region
resource "aws_lambda_function" "rds_copy_snapshot" {
  count         = "${var.enable ? 1 : 0}"
  function_name = "rds_copy_snapshot"
  role          = "${aws_iam_role.iam_for_lambda.arn}"
  handler       = "shipper.lambda_handler"

  filename         = "${local.filename}"
  source_code_hash = "${base64sha256(file("${local.filename}"))}"

  runtime = "python2.7"
  timeout = "120"

  environment {
    variables = {
      SOURCE_REGION = "${var.aws_source_region}"
      TARGET_REGION = "${var.aws_destination_region}"
      DB_INSTANCES  = "${join(",",var.db_instances)}"
      KMS_KEY_ID    = "${aws_kms_key.dr_key.arn}"
    }
  }
}

#Creation of lambda function to create snapshots

resource "aws_lambda_function" "rds_create_snapshot" {
  count         = "${var.enable ? 1 : 0}"
  function_name = "rds_create_snapshot"
  role          = "${aws_iam_role.iam_for_lambda.arn}"
  handler       = "create_snapshot.lambda_handler"

  filename         = "${local.filename}"
  source_code_hash = "${base64sha256(file("${local.filename}"))}"

  runtime = "python2.7"
  timeout = "120"

  environment {
    variables = {
      SOURCE_REGION = "${var.aws_source_region}"
      DB_INSTANCES  = "${join(",",var.db_instances)}"
    }
  }
}

#Creation of lambda function to remove snapshots in remote region

resource "aws_lambda_function" "remove_snapshot_retention" {
  count         = "${var.enable ? 1 : 0}"
  function_name = "remove_snapshot_retention"
  role          = "${aws_iam_role.iam_for_lambda.arn}"
  handler       = "remove_snapshots.lambda_handler"

  filename         = "${local.filename}"
  source_code_hash = "${base64sha256(file("${local.filename}"))}"

  runtime = "python2.7"
  timeout = "120"

  environment {
    variables = {
      TARGET_REGION = "${var.aws_destination_region}"
      DB_INSTANCES  = "${join(",",var.db_instances)}"
      RETENTION     = "${var.retention}"
    }
  }
}

#Creation of SNS topic for RDS backup events
resource "aws_sns_topic" "rds-backup-events" {
  count = "${var.enable ? 1 : 0}"
  name  = "rds-backup-events"
}

#Creation of RDS event subscription to notify the SNS topic a backup has been created
resource "aws_db_event_subscription" "default" {
  count     = "${var.enable ? 1 : 0}"
  name      = "rds-manual-snapshot"
  sns_topic = "${aws_sns_topic.rds-backup-events.arn}"

  source_type = "db-instance"
  source_ids  = ["${var.db_instances}"]

  event_categories = [
    "backup",
  ]
}

#Linking the topic to trigger a lambda function
resource "aws_sns_topic_subscription" "lambda_subscription" {
  count     = "${var.enable ? 1 : 0}"
  topic_arn = "${aws_sns_topic.rds-backup-events.arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.rds_copy_snapshot.arn}"
}

#Creation of permissions to allow sns to trigger lambda function
resource "aws_lambda_permission" "with_sns" {
  count         = "${var.enable ? 1 : 0}"
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.rds_copy_snapshot.arn}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${aws_sns_topic.rds-backup-events.arn}"
}

#Creation of cronjobs 
#Job for triggering backups
resource "aws_cloudwatch_event_rule" "every_6_hours" {
  count               = "${var.enable ? 1 : 0}"
  name                = "every_6_hours"
  description         = "Fires every 6 hours"
  schedule_expression = "rate(6 hours)"
}

#Job for cleaning up old retention
resource "aws_cloudwatch_event_rule" "every_24_hours" {
  count               = "${var.enable ? 1 : 0}"
  name                = "every_24_hours"
  description         = "Fires every 24 hours"
  schedule_expression = "rate(24 hours)"
}

resource "aws_cloudwatch_event_target" "activate_lambda_cron" {
  count     = "${var.enable ? 1 : 0}"
  rule      = "${aws_cloudwatch_event_rule.every_6_hours.name}"
  target_id = "rds-backup"
  arn       = "${aws_lambda_function.rds_create_snapshot.arn}"
}

resource "aws_cloudwatch_event_target" "activate_lambda_removal_cron" {
  count     = "${var.enable ? 1 : 0}"
  rule      = "${aws_cloudwatch_event_rule.every_24_hours.name}"
  target_id = "rds-retention-removal"
  arn       = "${aws_lambda_function.remove_snapshot_retention.arn}"
}
