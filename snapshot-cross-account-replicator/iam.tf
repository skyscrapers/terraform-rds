locals {
  snapshot_arns       = [for rds in data.aws_db_instance.rds : "arn:aws:rds:${data.aws_region.source.name}:${data.aws_caller_identity.source.account_id}:snapshot:${rds.db_instance_identifier}_*"]
  source_kms_key_ids  = compact([for rds in data.aws_db_instance.rds : rds.kms_key_id])
  source_kms_key_arns = [for key in local.source_kms_key_ids : "arn:aws:kms:${data.aws_region.source.name}:${data.aws_caller_identity.source.account_id}:key/${key}"]
}

## Source account

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  provider = aws.source
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    effect = "Allow"
  }
}

resource "aws_iam_role" "lambda" {
  provider           = aws.source
  name               = "rds_snapshot_replicator_lambda_${var.name}"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

data "aws_iam_policy_document" "lambda_permissions" {
  provider = aws.source
  statement {
    effect = "Allow"
    actions = [
      "rds:CreateDBSnapshot",
      "rds:Describe*",
    ]
    resources = [for rds in data.aws_db_instance.rds : rds.db_instance_arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "rds:DeleteDBSnapshot",
      "rds:ModifyDBSnapshot"
    ]
    resources = local.snapshot_arns
  }
}

resource "aws_iam_role_policy" "lambda" {
  provider = aws.source
  role     = aws_iam_role.lambda.name
  policy   = data.aws_iam_policy_document.lambda_permissions.json
}

resource "aws_iam_role_policy_attachment" "lambda_exec_role" {
  provider   = aws.source
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

## Target account

data "aws_iam_policy_document" "target_lambda_assume_role_policy" {
  provider = aws.target
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.lambda.arn]
    }
    effect = "Allow"
  }
}

resource "aws_iam_role" "target_lambda" {
  provider           = aws.target
  name               = "rds_snapshot_replicator_lambda_target_${var.name}"
  assume_role_policy = data.aws_iam_policy_document.target_lambda_assume_role_policy.json
}

data "aws_iam_policy_document" "target_lambda_permissions" {
  provider = aws.target

  statement {
    effect = "Allow"
    actions = [
      "rds:CopyDBSnapshot",
      "rds:ModifyDBSnapshot"
    ]
    resources = local.snapshot_arns
  }
}

resource "aws_iam_role_policy" "target_lambda" {
  provider = aws.target
  role     = aws_iam_role.target_lambda.name
  policy   = data.aws_iam_policy_document.target_lambda_permissions.json
}

data "aws_iam_policy_document" "target_lambda_kms_permissions" {
  provider = aws.target
  count    = length(local.source_kms_key_arns) > 0 ? 1 : 0 # Not needed if there are no kms keys

  statement {
    sid    = "AllowUseOfTheKey"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "kms:CreateGrant",
      "kms:RetireGrant"
    ]
    resources = local.source_kms_key_arns
  }

  statement {
    sid    = "AllowAttachmentOfPersistentResources"
    effect = "Allow"
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]
    resources = local.source_kms_key_arns
    condition {
      test     = "Bool"
      values   = [true]
      variable = "kms:GrantIsForAWSResource"
    }
  }
}

resource "aws_iam_role_policy" "target_lambda_kms" {
  provider = aws.target
  count    = length(local.source_kms_key_arns) > 0 ? 1 : 0 # Not needed if there are no kms keys
  role     = aws_iam_role.target_lambda.name
  policy   = data.aws_iam_policy_document.target_lambda_kms_permissions[0].json
}
