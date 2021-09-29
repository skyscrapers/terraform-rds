locals {
  source_snapshot_arns = [for rds in data.aws_db_instance.rds : "arn:aws:rds:${data.aws_region.source.name}:${data.aws_caller_identity.source.account_id}:snapshot:${rds.db_instance_identifier}-*"]
  target_snapshot_arns = [for rds in data.aws_db_instance.rds : "arn:aws:rds:${data.aws_region.target.name}:${data.aws_caller_identity.target.account_id}:snapshot:${rds.db_instance_identifier}-*"]

  ### Gather the KMS keys used by the configured RDS instances
  source_kms_key_ids = compact([for rds in data.aws_db_instance.rds : rds.kms_key_id])
}

## IAM resources on the source account

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
    sid    = "AllowCreateSnapshots"
    effect = "Allow"
    actions = [
      "rds:CreateDBSnapshot",
      "rds:Describe*",
    ]
    resources = [for rds in data.aws_db_instance.rds : rds.db_instance_arn]
  }

  statement {
    sid    = "AllowCreateDeleteAndShareSnapshots"
    effect = "Allow"
    actions = [
      "rds:CreateDBSnapshot",
      "rds:DeleteDBSnapshot",
      "rds:ModifyDBSnapshot",
      "rds:ModifyDBSnapshotAttribute",
      "rds:AddTagsToResource",
      "rds:DescribeDBSnapshots"
    ]
    resources = local.source_snapshot_arns
  }

  statement {
    sid       = "AllowAssumeRoleInTargetAccount"
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = [aws_iam_role.target_lambda.arn]
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

## IAM resources on the target account

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

#### This role is to be assumed by the Lambda function in the source account
#### to trigger a copy of the shared snapshots in the target account.
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
      "rds:ModifyDBSnapshot",
      "rds:DescribeDBSnapshots",
      "rds:AddTagsToResource"
    ]
    resources = concat(local.source_snapshot_arns, local.target_snapshot_arns)
  }
}

resource "aws_iam_role_policy" "target_lambda" {
  provider = aws.target
  role     = aws_iam_role.target_lambda.name
  policy   = data.aws_iam_policy_document.target_lambda_permissions.json
}

#### This policy grants usage access to the Lambda function in the target account
#### to the KMS keys used to encrypt the RDS snapshots in the source account.
data "aws_iam_policy_document" "target_lambda_kms_permissions" {
  provider = aws.target

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

resource "aws_iam_role_policy" "target_lambda_kms" {
  provider = aws.target
  role     = aws_iam_role.target_lambda.name
  policy   = data.aws_iam_policy_document.target_lambda_kms_permissions.json
}
