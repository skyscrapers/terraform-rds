resource "aws_db_proxy" "proxy" {
  name                   = "${var.project}-${var.environment}-rds-proxy"
  debug_logging          = false
  engine_family          = var.engine
  role_arn               = aws_iam_role.proxy.arn
  vpc_security_group_ids = var.security_groups
  vpc_subnet_ids         = var.subnets

  auth {
    auth_scheme = "SECRETS"
    iam_auth    = "DISABLED"
    secret_arn  = var.db_secret_arn
  }

  tags = {
    Name        = "${var.project}-${var.environment}-rds-proxy"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_db_proxy_default_target_group" "default" {
  db_proxy_name = aws_db_proxy.proxy.name
}

resource "aws_db_proxy_target" "target" {
  db_instance_identifier = var.db_instance_identifier
  db_proxy_name          = aws_db_proxy.proxy.db_proxy_name
  target_group_name      = aws_db_proxy_default_target_group.default.name
}

resource "aws_iam_role" "proxy_secret_access_role" {
  name               = "${var.project}-${var.environment}_rds_proxy"
  assume_role_policy = data.aws_iam_policy_document.task_assume.json
}

data "aws_iam_policy_document" "task_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "proxy_secret_access" {
  name   = "${var.project}-${var.environment}_rds_proxy"
  role   = aws_iam_role.proxy_secret_access_role.id
  policy = data.aws_iam_policy_document.proxy_secret_access_policy.json
}

data "aws_iam_policy_document" "proxy_secret_access_policy" {
  statement {
    effect = "Allow"

    resources = [var.db_secret_arn]

    actions = ["secretsmanager:GetSecretValue"]
  }
}
