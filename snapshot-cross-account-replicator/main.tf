terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      version = ">= 3.61.0"
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
  for_each           = var.is_aurora_cluster ? toset(var.rds_instance_ids) : 0
  cluster_identifier = each.key
}

data "aws_db_instance" "rds" {
  provider               = aws.source
  for_each               = ! var.is_aurora_cluster ? toset(var.rds_instance_ids) : 0
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
    SOURCE_ACCOUNT_IAM_ROLE    = aws_iam_role.step_4_lambda.arn
    TARGET_REGION              = data.aws_region.target.name
    TARGET_ACCOUNT_KMS_KEY_ARN = data.aws_kms_key.target_key.arn
    RDS_INSTANCE_IDS           = join(",", var.rds_instance_ids)
    SETUP_NAME                 = local.setup_name
    TYPE                       = "cross-account"
    SOURCE_REGION              = data.aws_region.source.name
    RETENTION_PERIOD           = var.retention_period
    IS_CLUSTER                 = var.is_aurora_cluster
  }

  event_rule_pattern = [for id in var.rds_instance_ids : {
    prefix = "${id}-"
  }]
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda.zip"
  source_dir  = "${path.module}/functions/"
}
