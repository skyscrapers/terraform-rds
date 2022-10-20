terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      version = "~> 3.61"
      configuration_aliases = [
        aws.source,
        aws.intermediate,
        aws.target
      ]
    }
  }
}

data "aws_caller_identity" "source" {
  provider = aws.source
}

data "aws_region" "source" {
  provider = aws.source
}

data "aws_region" "intermediate" {
  provider = aws.intermediate
}

data "aws_caller_identity" "target" {
  provider = aws.target
}

data "aws_region" "target" {
  provider = aws.target
}

data "aws_rds_cluster" "rds" {
  provider           = aws.source
  for_each           = var.is_aurora_cluster ? toset(var.rds_instance_ids) : []
  cluster_identifier = each.key
}

data "aws_db_instance" "rds" {
  provider               = aws.source
  for_each               = !var.is_aurora_cluster ? toset(var.rds_instance_ids) : []
  db_instance_identifier = each.key
}

data "aws_kms_key" "target_key" {
  provider = aws.target
  key_id   = var.target_account_kms_key_id
}

locals {
  setup_name = "rds-snapshot-cross-account-replicator-${var.name}"

  lambda_default_environment_variables = {
    TARGET_ACCOUNT_ID          = data.aws_caller_identity.target.account_id
    TARGET_ACCOUNT_IAM_ROLE    = aws_iam_role.target_lambda.arn
    TARGET_REGION              = data.aws_region.target.name
    TARGET_ACCOUNT_KMS_KEY_ARN = data.aws_kms_key.target_key.arn
    RDS_INSTANCE_IDS           = join(",", var.rds_instance_ids)
    SETUP_NAME                 = local.setup_name
    TYPE                       = "cross-account"
    SOURCE_REGION              = data.aws_region.source.name
    RETENTION_PERIOD           = var.retention_period
    IS_CLUSTER                 = tostring(var.is_aurora_cluster)
  }

  event_rule_pattern = [for id in var.rds_instance_ids : {
    prefix = "${id}-"
  }]

  invoke_step_2_lambda_event_pattern_cluster = <<EOF
{
  "detail-type": ["RDS DB Cluster Snapshot Event"],
  "source": ["aws.rds"],
  "region": ["${data.aws_region.source.name}"],
  "detail": {
    "EventCategories": ["backup"],
    "SourceType": ["CLUSTER_SNAPSHOT"],
    "Message": ["Manual cluster snapshot created"],
    "SourceIdentifier": ${jsonencode(local.event_rule_pattern)},
    "EventID": ["RDS-EVENT-0075"]
  }
}
EOF

  invoke_step_2_lambda_event_pattern_instance = <<EOF
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

  invoke_step_3_lambda_event_pattern_instance = <<EOF
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

data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda.zip"
  source_dir  = "${path.module}/functions/"
}
