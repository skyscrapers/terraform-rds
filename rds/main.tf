locals {
  default_ports = {
    mysql    = "3306"
    postgres = "5432"
    oracle   = "1521"
  }

  default_db_parameters = {
    mysql = [
      {
        name  = "slow_query_log"
        value = "1"
      },
      {
        name  = "long_query_time"
        value = "1"
      },
      {
        name  = "general_log"
        value = "0"
      },
      {
        name  = "log_output"
        value = "FILE"
      },
    ]
    postgres = []
    oracle   = []
  }

  port = local.default_ports[var.engine]
}

resource "aws_db_subnet_group" "rds" {
  name        = coalesce(var.subnet_group_name_override, var.name, "${var.project}-${var.environment}${var.tag}-rds")
  description = "Our main group of subnets"
  subnet_ids  = var.subnets
}

resource "aws_db_parameter_group" "rds" {
  name_prefix = "${length(var.name) == 0 ? "${var.engine}-${var.project}-${var.environment}${var.tag}" : var.name}-"
  family      = var.default_parameter_group_family
  description = "RDS ${var.project} ${var.environment} parameter group for ${var.engine}"
  dynamic "parameter" {
    for_each = local.default_db_parameters[var.engine]
    content {

      apply_method = lookup(parameter.value, "apply_method", null)
      name         = parameter.value.name
      value        = parameter.value.value
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_instance" "rds" {
  identifier                            = length(var.name) == 0 ? "${var.project}-${var.environment}${var.tag}-rds${var.number}" : var.name
  allocated_storage                     = var.storage
  max_allocated_storage                 = var.max_allocated_storage
  engine                                = var.engine
  engine_version                        = var.engine_version
  instance_class                        = var.size
  storage_type                          = var.storage_type
  username                              = var.rds_username
  password                              = var.rds_password
  vpc_security_group_ids                = [aws_security_group.sg_rds.id]
  db_subnet_group_name                  = aws_db_subnet_group.rds.id
  parameter_group_name                  = var.rds_custom_parameter_group_name == "" ? aws_db_parameter_group.rds.id : var.rds_custom_parameter_group_name
  multi_az                              = var.multi_az
  backup_retention_period               = var.backup_retention_period
  storage_encrypted                     = var.storage_encrypted
  kms_key_id                            = var.storage_kms_key_id
  apply_immediately                     = var.apply_immediately
  skip_final_snapshot                   = var.skip_final_snapshot
  final_snapshot_identifier             = "${length(var.name) == 0 ? "${var.project}-${var.environment}${var.tag}-rds${var.number}" : var.name}-final-${md5(timestamp())}"
  availability_zone                     = var.availability_zone
  snapshot_identifier                   = var.snapshot_identifier
  monitoring_interval                   = var.monitoring_interval
  auto_minor_version_upgrade            = var.auto_minor_version_upgrade
  enabled_cloudwatch_logs_exports       = var.enabled_cloudwatch_logs_exports
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period
  performance_insights_kms_key_id       = var.performance_insights_kms_key_id
  deletion_protection                   = var.deletion_protection
  publicly_accessible                   = var.publicly_accessible
  maintenance_window                    = var.maintenance_window

  tags = merge({
    Name        = length(var.name) == 0 ? "${var.project}-${var.environment}${var.tag}-rds${var.number}" : var.name
    Environment = var.environment
    Project     = var.project
    },
    var.extra_tags
  )

  lifecycle {
    ignore_changes = [final_snapshot_identifier]
  }

  # This prevents the rules to be deleted first on a Terraform destroy
  # The security group rules must be deleted after the instance is destroyed, otherwise there
  # might be database resources (e.g. mysql or postgresql databases) that won't be able to be
  # deleted by Terraform because the client doesn't have access.
  depends_on = [aws_security_group_rule.rds_sg_in, aws_security_group_rule.rds_cidr_in]
}
