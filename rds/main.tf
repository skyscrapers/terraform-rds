#lookup parameters for specic RDS types
variable "ports" {
  default = {
    mysql    = "3306"
    oracle   = "1521"
    postgres = "5432"
  }
}

variable "families" {
  default = {
    mysql    = "mysql5.6"
    oracle   = "oracle-se2-12.1"
    postgres = "postgres9.5"
  }
}

variable "engines" {
  default = {
    mysql    = "mysql"
    oracle   = "oracle-se2"
    postgres = "postgres"
  }
}

variable "engine_versions" {
  default = {
    mysql    = "5.6.22"
    oracle   = "12.1.0.2.v2"
    postgres = "9.5.4"
  }
}

resource "aws_db_subnet_group" "rds" {
  name        = "${var.project}-${var.environment}${var.tag}-rds"
  description = "Our main group of subnets"
  subnet_ids  = ["${var.subnets}"]
}

resource "aws_db_parameter_group" "rds_mysql" {
  name        = "mysql-rds-${var.project}-${var.environment}${var.tag}"
  family      = "${lookup(var.families, "mysql")}"
  description = "rds ${var.project} ${var.environment} parameter group for mysql"

  parameter = {
    name = "slow_query_log"

    value = "1"
  }

  parameter = {
    name = "long_query_time"

    value = "1"
  }

  parameter = {
    name = "general_log"

    value = "0"
  }

  parameter = {
    name = "log_output"

    value = "FILE"
  }
}

resource "aws_db_parameter_group" "rds_oracle" {
  name        = "oracle-rds-${var.project}-${var.environment}${var.tag}"
  family      = "${lookup(var.families, "oracle")}"
  description = "rds ${var.project} ${var.environment} parameter group for oracle"

  parameter = {
    name = "db_block_checking"

    value = "MEDIUM"
  }
}

resource "aws_db_parameter_group" "rds_postgres" {
  name        = "postgres-rds-${var.project}-${var.environment}${var.tag}"
  family      = "${lookup(var.families, "postgres")}"
  description = "rds ${var.project} ${var.environment} parameter group for postgres"
}

resource "aws_db_instance" "rds" {
  identifier              = "${var.project}-${var.environment}${var.tag}-rds${var.number}"
  allocated_storage       = "${var.storage}"
  engine                  = "${lookup(var.engines, var.rds_type)}"
  engine_version          = "${lookup(var.engine_versions, var.rds_type)}"
  instance_class          = "${var.size}"
  storage_type            = "${var.storage_type}"
  username                = "root"
  password                = "${var.rds_password}"
  vpc_security_group_ids  = ["${aws_security_group.sg_rds.id}"]
  db_subnet_group_name    = "${aws_db_subnet_group.rds.id}"
  parameter_group_name    = "${var.rds_parameter_group_name}"
  multi_az                = "${var.multi_az}"
  replicate_source_db     = "${var.replicate_source_db}"
  backup_retention_period = "${var.backup_retention_period}"
  storage_encrypted       = "${var.storage_encrypted}"
  apply_immediately       = "${var.apply_immediately}"
  skip_final_snapshot     = false

  tags {
    Name        = "${var.project}-${var.environment}${var.tag}-rds${var.number}"
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }

  depends_on = ["aws_db_parameter_group.rds_mysql", "aws_db_parameter_group.rds_oracle", "aws_db_parameter_group.rds_postgres"]
}
