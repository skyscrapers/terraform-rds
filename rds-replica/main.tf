resource "aws_db_subnet_group" "rds" {
  count       = var.number_of_replicas > 0 ? var.subnets == null ? 0 : 1 : 0
  name        = length(var.name) == 0 ? "${var.project}-${var.environment}${var.tag}-rds-replica" : var.name
  description = "The group of subnets"
  subnet_ids  = var.subnets
}

data "aws_db_instance" "master" {
  db_instance_identifier = var.replicate_source_db
}

resource "aws_db_instance" "rds" {
  count                           = var.number_of_replicas
  identifier                      = length(var.name) == 0 ? "${var.project}-${var.environment}${var.tag}-rds${count.index + 1}-replica" : var.name
  engine                          = var.engine
  instance_class                  = var.size
  multi_az                        = var.multi_az
  vpc_security_group_ids          = [aws_security_group.sg_rds[0].id]
  replicate_source_db             = var.replicate_source_db
  publicly_accessible             = var.publicly_accessible
  db_subnet_group_name            = var.subnets == null ? null : aws_db_subnet_group.rds[0].id
  storage_encrypted               = var.storage_encrypted
  allocated_storage               = var.allocated_storage
  max_allocated_storage           = var.max_allocated_storage
  parameter_group_name            = var.custom_parameter_group_name == "" ? data.aws_db_instance.master.db_parameter_groups[0] : var.custom_parameter_group_name
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  backup_retention_period         = var.backup_retention_period
  auto_minor_version_upgrade      = var.auto_minor_version_upgrade
  skip_final_snapshot             = true

  tags = merge({
    Name        = length(var.name) == 0 ? "${var.project}-${var.environment}${var.tag}-rds${count.index + 1}-replica" : var.name
    Environment = var.environment
    Project     = var.project
  },
    var.extra_tags
  )

  lifecycle {
    ignore_changes = [replicate_source_db]
  }
}
