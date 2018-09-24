resource "aws_kms_key" "dr_key" {
  provider                = "aws.eu-central-1"
  description             = "DR RDS KEY"
  deletion_window_in_days = 10
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "default_lambda"

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
  name = "rds_lambda_copy"

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
  role       = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "${aws_iam_policy.rds_lambda_copy.arn}"
}

resource "aws_iam_policy" "rds_lambda_create_snapshot" {
  name = "rds_lambda_create_snapshot"

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
  role       = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "${aws_iam_policy.rds_lambda_create_snapshot.arn}"
}

resource "aws_iam_role" "states_execution_role" {
  name = "states_execution_role"

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
  name = "states_execution_policy"

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
  role       = "${aws_iam_role.states_execution_role.name}"
  policy_arn = "${aws_iam_policy.states_execution_policy.arn}"
}

# resource "aws_iam_role" "aws_event_invoke_step_function_role" {
#   name = "aws_event_invoke_step_function_role"

#   assume_role_policy = <<EOF
#   {
#   	"Version": "2012-10-17",
#   	"Statement": [{
#   		"Effect": "Allow",
#   		"Principal": {
#   			"Service": "events.amazonaws.com"
#   		},
#   		"Action": "sts:AssumeRole"
#   	}]
#   }
# EOF
# }

# resource "aws_iam_policy" "aws_event_invoke_step_function_policy" {
#   name = "aws_event_invoke_step_function_policy"

#   policy = <<EOF
# {
# 	"Version": "2012-10-17",
# 	"Statement": [{
# 		"Effect": "Allow",
# 		"Action": [
# 			"states:StartExecution"
# 		],
# 		"Resource": [
# 			"arn:aws:states:*"
# 		]
# 	}]
# }
# EOF
# }

# resource "aws_iam_role_policy_attachment" "attach_aws_event_invoke_step_to_role" {
#   role       = "${aws_iam_role.aws_event_invoke_step_function_role.name}"
#   policy_arn = "${aws_iam_policy.aws_event_invoke_step_function_policy.arn}"
# }

# resource "aws_sfn_state_machine" "temp" {
#   name     = "rds-backup"
#   role_arn = "${aws_iam_role.states_execution_role.name}"

#   definition = <<EOF
# {
#   "Comment": "Create a snapshot for a defined DB's",
#   "StartAt": "CreateRDSSnapshot",
#   "States": {
#     "CreateRDSSnapshot": {
#       "Type": "Task",
#       "Resource": "${aws_lambda_function.rds_create_snapshot.arn}",
#       "End": true
#     }
#   }
# }
# EOF
# }

data "archive_file" "create_zip" {
  type        = "zip"
  output_path = "${path.module}/shipper.zip"

  source_dir = "${path.module}/functions/"
}

locals {
  # Solution from this comment to open issue on non-relative paths  # https://github.com/hashicorp/terraform/issues/8204#issuecomment-332239294

  filename = "${substr(data.archive_file.create_zip.output_path, length(path.cwd) + 1, -1)}"

  // +1 for removing the "/"
}

resource "aws_lambda_function" "rds_copy_snapshot" {
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
      DB_INSTANCES  = "${var.db_instances}"
    }
  }
}

resource "aws_lambda_function" "rds_create_snapshot" {
  function_name = "rds_create_snapshot"
  role          = "${aws_iam_role.iam_for_lambda.arn}"
  handler       = "create_snapshot.lambda_handler"

  filename         = "${local.filename}"
  source_code_hash = "${base64sha256(file("${local.filename}"))}"

  runtime = "python2.7"
  timeout = "120"

  environment {
    variables = {
      SOURCE_REGION      = "${var.aws_source_region}"
      DESTINATION_REGION = "${var.aws_destination_region}"
      DB_INSTANCES       = "${var.db_instances}"
      KMS_KEY_ID         = "${aws_kms_key.dr_key.arn}"
    }
  }
}

resource "aws_lambda_function" "remove_snapshot_retention" {
  function_name = "remove_snapshot_retention"
  role          = "${aws_iam_role.iam_for_lambda.arn}"
  handler       = "remove_snapshots.lambda_handler"

  filename         = "${local.filename}"
  source_code_hash = "${base64sha256(file("${local.filename}"))}"

  runtime = "python2.7"
  timeout = "120"

  environment {
    variables = {
      DESTINATION_REGION = "${var.aws_destination_region}"
      DB_INSTANCES       = "${var.db_instances}"
    }
  }
}

resource "aws_sns_topic" "rds-backup-events" {
  name = "rds-backup-events"
}

resource "aws_db_event_subscription" "default" {
  name      = "rds-manual-snapshot"
  sns_topic = "${aws_sns_topic.rds-backup-events.arn}"

  source_type = "db-instance"
  source_ids  = ["${var.db_instances}"]

  event_categories = [
    "backup",
  ]
}

resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = "${aws_sns_topic.rds-backup-events.arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.rds_copy_snapshot.arn}"
}

resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.rds_copy_snapshot.arn}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${aws_sns_topic.rds-backup-events.arn}"
}

resource "aws_cloudwatch_event_rule" "every_6_hours" {
  name                = "every_6_hours"
  description         = "Fires every 6 hours"
  schedule_expression = "rate(6 hours)"
}
resource "aws_cloudwatch_event_rule" "every_24_hours" {
  name                = "every_24_hours"
  description         = "Fires every 24 hours"
  schedule_expression = "rate(24 hours)"
}

resource "aws_cloudwatch_event_target" "activate_lambda_cron" {
  rule      = "${aws_cloudwatch_event_rule.every_6_hours.name}"
  target_id = "rds-backup"
  arn       = "${aws_lambda_function.rds_create_snapshot.arn}"
}
resource "aws_cloudwatch_event_target" "activate_lambda_removal_cron" {
  rule      = "${aws_cloudwatch_event_rule.every_24_hours.name}"
  target_id = "rds-retention-removal"
  arn       = "${aws_lambda_function.remove_snapshot_retention.arn}"
}

