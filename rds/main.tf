#lookup parameters for specic RDS types
variable "default_db_parameters" {
  default = {
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
}

variable "default_ports" {
  default = {
    mysql    = "3306"
    postgres = "5432"
    oracle   = "1521"
  }
}

locals {
  port = "${var.default_ports[var.engine]}"
}

resource "aws_db_subnet_group" "rds" {
  name        = "${length(var.name) == 0 ? "${var.project}-${var.environment}${var.tag}-rds" : var.name}"
  description = "Our main group of subnets"
  subnet_ids  = ["${var.subnets}"]
}

resource "aws_db_parameter_group" "rds" {
  count       = "${length(var.rds_custom_parameter_group_name) == 0 ? 1 : 0}"
  name_prefix = "${length(var.name) == 0 ? "${var.engine}-${var.project}-${var.environment}${var.tag}" : var.name}-"
  family      = "${var.default_parameter_group_family}"
  description = "RDS ${var.project} ${var.environment} parameter group for ${var.engine}"
  parameter   = "${var.default_db_parameters[var.engine]}"
}

resource "aws_db_instance" "rds" {
  identifier                = "${length(var.name) == 0 ? "${var.project}-${var.environment}${var.tag}-rds${var.number}" : var.name}"
  allocated_storage         = "${var.storage}"
  engine                    = "${var.engine}"
  engine_version            = "${var.engine_version}"
  instance_class            = "${var.size}"
  storage_type              = "${var.storage_type}"
  username                  = "${var.rds_username}"
  password                  = "${var.rds_password}"
  vpc_security_group_ids    = ["${aws_security_group.sg_rds.id}"]
  db_subnet_group_name      = "${aws_db_subnet_group.rds.id}"
  parameter_group_name      = "${length(var.rds_custom_parameter_group_name) > 0 ? var.rds_custom_parameter_group_name : aws_db_parameter_group.rds.name}"
  multi_az                  = "${var.multi_az}"
  replicate_source_db       = "${var.replicate_source_db}"
  backup_retention_period   = "${var.backup_retention_period}"
  storage_encrypted         = "${var.storage_encrypted}"
  apply_immediately         = "${var.apply_immediately}"
  skip_final_snapshot       = "${var.skip_final_snapshot}"
  final_snapshot_identifier = "${var.project}-${var.environment}${var.tag}-rds${var.number}-final-${md5(timestamp())}"
  availability_zone         = "${var.availability_zone}"
  snapshot_identifier       = "${var.snapshot_identifier}"

  tags {
    Name        = "${length(var.name) == 0 ? "${var.project}-${var.environment}${var.tag}-rds${var.number}" : var.name}"
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }

  lifecycle {
    ignore_changes = ["final_snapshot_identifier"]
  }
}
