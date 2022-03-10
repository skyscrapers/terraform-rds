resource "aws_iam_role" "proxy_secret_access_role" {
  name               = "${var.project}-${var.environment}_rds_proxy"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
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

    resources = var.db_secret_arns

    actions = ["secretsmanager:GetSecretValue"]
  }
}

resource "aws_db_proxy" "proxy" {
  name                   = "${var.project}-${var.environment}-rds-proxy"
  debug_logging          = false
  engine_family          = var.engine
  role_arn               = aws_iam_role.proxy_secret_access_role.arn
  vpc_security_group_ids = var.security_groups
  vpc_subnet_ids         = var.subnets

  dynamic "auth" {
    for_each = var.db_secret_arns
    content {
      auth_scheme = "SECRETS"
      iam_auth    = "DISABLED"
      secret_arn  = auth.value
    }
  }

  tags = merge({
    Name        = "${var.project}-${var.environment}-rds-proxy"
    Environment = var.environment
    Project     = var.project
    },
    var.extra_tags
  )
}

resource "aws_db_proxy_default_target_group" "default" {
  db_proxy_name = aws_db_proxy.proxy.name
  connection_pool_config {
    connection_borrow_timeout = var.proxy_connection_timeout
    max_connections_percent   = var.proxy_max_connection_percent
  }
}

resource "aws_db_proxy_target" "target" {
  db_instance_identifier = var.db_instance_identifier
  db_proxy_name          = aws_db_proxy.proxy.name
  target_group_name      = aws_db_proxy_default_target_group.default.name
}


