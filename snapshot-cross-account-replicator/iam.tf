locals {
  source_snapshot_arns = [for id in var.rds_instance_ids : "arn:aws:rds:${data.aws_region.source.name}:${data.aws_caller_identity.source.account_id}:${var.is_aurora_cluster ? "cluster-" : ""}snapshot:${id}-*"]

  intermediate_snapshot_arns = [for id in var.rds_instance_ids : "arn:aws:rds:${data.aws_region.intermediate.name}:${data.aws_caller_identity.source.account_id}:${var.is_aurora_cluster ? "cluster-" : ""}snapshot:${id}-*"]

  target_snapshot_arns = [for id in var.rds_instance_ids : "arn:aws:rds:${data.aws_region.target.name}:${data.aws_caller_identity.target.account_id}:${var.is_aurora_cluster ? "cluster-" : ""}snapshot:${id}-*"]

  ### Gather the KMS keys used by the configured RDS instances
  source_kms_key_ids = var.is_aurora_cluster ? compact([for rds in data.aws_rds_cluster.rds : rds.kms_key_id]) : compact([for rds in data.aws_db_instance.rds : rds.kms_key_id])
}

## IAM resources on the source account

data "aws_iam_policy_document" "source_lambda_assume_role_policy" {
  provider = aws.source
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

## This role is to be assumed by step 1, step 2 and step 3 Lambda functions
resource "aws_iam_role" "source_lambda" {
  provider           = aws.source
  name               = "rds_snapshots_replicator_lambda_${var.name}"
  assume_role_policy = data.aws_iam_policy_document.source_lambda_assume_role_policy.json
}

data "aws_iam_policy_document" "source_lambda_permissions" {
  provider = aws.source

  statement {
    sid    = "AllowCreateSnapshots"
    effect = "Allow"
    actions = [
      "rds:CreateDBClusterSnapshot",
      "rds:CreateDBSnapshot",
      "rds:Describe*",
    ]
    resources = var.is_aurora_cluster ? [for rds in data.aws_rds_cluster.rds : rds.arn] : [for rds in data.aws_db_instance.rds : rds.db_instance_arn]
  }

  statement {
    sid    = "AllowCreateDeleteAndShareSnapshots"
    effect = "Allow"
    actions = [
      "rds:CreateDBClusterSnapshot",
      "rds:DeleteDBClusterSnapshot",
      "rds:ModifyDBClusterSnapshot",
      "rds:ModifyDBClusterSnapshotAttribute",
      "rds:DescribeDBClusterSnapshots",
      "rds:CopyDBClusterSnapshot",
      "rds:CreateDBSnapshot",
      "rds:DeleteDBSnapshot",
      "rds:ModifyDBSnapshot",
      "rds:ModifyDBSnapshotAttribute",
      "rds:DescribeDBSnapshots",
      "rds:CopyDBSnapshot",
      "rds:AddTagsToResource"
    ]
    resources = concat(local.source_snapshot_arns, local.intermediate_snapshot_arns)
  }

  statement {
    sid    = "AllowDescribeAndTagSnapshots"
    effect = "Allow"
    actions = [
      "rds:DescribeDBClusterSnapshots",
      "rds:DescribeDBSnapshots",
      "rds:ListTagsForResource",
      "rds:AddTagsToResource"
    ]
    resources = ["*"]
  }

  statement {
    sid       = "AllowAssumeRoleInTargetAccount"
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = [aws_iam_role.target_lambda.arn]
  }
}

resource "aws_iam_role_policy" "source_lambda" {
  provider = aws.source
  role     = aws_iam_role.source_lambda.name
  policy   = data.aws_iam_policy_document.source_lambda_permissions.json
}

resource "aws_iam_role_policy_attachment" "source_lambda_exec_role" {
  provider   = aws.source
  role       = aws_iam_role.source_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#### This policy grants usage access to the Lambda function in the source account
#### to the KMS keys used to encrypt the RDS snapshots in the target account.
data "aws_iam_policy_document" "lambda_kms_permissions" {
  provider = aws.source

  statement {
    sid    = "AllowUseOfTheKey"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = concat(local.source_kms_key_ids, [data.aws_kms_key.target_key.arn])
  }

  statement {
    sid    = "AllowAttachmentOfPersistentResources"
    effect = "Allow"
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]
    resources = concat(local.source_kms_key_ids, [data.aws_kms_key.target_key.arn])
    condition {
      test     = "Bool"
      values   = [true]
      variable = "kms:GrantIsForAWSResource"
    }
  }
}

resource "aws_iam_role_policy" "source_lambda_kms" {
  provider = aws.source
  role     = aws_iam_role.source_lambda.name
  policy   = data.aws_iam_policy_document.lambda_kms_permissions.json
}

## IAM resources on the target account

data "aws_iam_policy_document" "target_lambda_assume_role_policy" {
  provider = aws.target
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.source_lambda.arn]
    }

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

#### This role is to be assumed by the Lambda function in the source account
#### to trigger a copy of the shared snapshots in the target account.
resource "aws_iam_role" "target_lambda" {
  provider           = aws.target
  name               = "rds_snapshots_replicator_lambda_target_${var.name}"
  assume_role_policy = data.aws_iam_policy_document.target_lambda_assume_role_policy.json
}

data "aws_iam_policy_document" "target_lambda_permissions" {
  provider = aws.target

  statement {
    effect = "Allow"
    actions = [
      "rds:DeleteDBClusterSnapshot",
      "rds:CopyDBClusterSnapshot",
      "rds:ModifyDBClusterSnapshot",
      "rds:DescribeDBClusterSnapshots",
      "rds:DeleteDBSnapshot",
      "rds:CopyDBSnapshot",
      "rds:ModifyDBSnapshot",
      "rds:DescribeDBSnapshots",
      "rds:AddTagsToResource"
    ]
    resources = concat(local.intermediate_snapshot_arns, local.target_snapshot_arns)
  }

  statement {
    sid    = "AllowDescribeSnapshots"
    effect = "Allow"
    actions = [
      "rds:DescribeDBClusterSnapshots",
      "rds:DescribeDBSnapshots",
      "rds:ListTagsForResource"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowUseOfTheKey"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = [data.aws_kms_key.target_key.arn]
  }

  statement {
    sid    = "AllowAttachmentOfPersistentResources"
    effect = "Allow"
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]
    resources = [data.aws_kms_key.target_key.arn]
    condition {
      test     = "Bool"
      values   = [true]
      variable = "kms:GrantIsForAWSResource"
    }
  }
}

resource "aws_iam_role_policy" "target_lambda" {
  provider = aws.target
  role     = aws_iam_role.target_lambda.name
  policy   = data.aws_iam_policy_document.target_lambda_permissions.json
}

resource "aws_iam_role_policy" "target_lambda_kms" {
  provider = aws.target
  role     = aws_iam_role.target_lambda.name
  policy   = data.aws_iam_policy_document.lambda_kms_permissions.json
}

resource "aws_iam_role_policy_attachment" "target_lambda_exec_role" {
  provider   = aws.target
  role       = aws_iam_role.target_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
