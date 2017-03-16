data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_db_subnet_group" "aurora" {
  name        = "${var.project}-${var.environment}${var.tag}-aurora"
  description = "Our main group of subnets"
  subnet_ids  = ["${var.subnets}"]
}

resource "aws_db_parameter_group" "aurora_mysql" {
  name        = "aurora-rds-${var.project}-${var.environment}${var.tag}"
  family      = "aurora5.6"
  description = "aurora ${var.project} ${var.environment} parameter group for mysql"

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

resource "aws_rds_cluster" "aurora" {
  cluster_identifier              = "${var.project}-${var.environment}${var.tag}-aurora"
  master_username                 = "root"
  master_password                 = "${var.password}"
  backup_retention_period         = "${var.backup_retention_period}"
  skip_final_snapshot             = "${var.skip_final_snapshot}"
  final_snapshot_identifier       = "${var.project}-${var.environment}${var.tag}-aurora-final-${md5(timestamp())}"
  availability_zones              = ["${data.aws_availability_zones.available.names}"]
  db_subnet_group_name            = "${aws_db_subnet_group.aurora.id}"
  vpc_security_group_ids          = ["${aws_security_group.sg_aurora.id}"]
  storage_encrypted               = "${var.storage_encrypted}"
  apply_immediately               = "${var.apply_immediately}"
  db_cluster_parameter_group_name = "${var.cluster_parameter_group_name}"

  tags {
    Name        = "${var.project}-${var.environment}${var.tag}-aurora"
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }

  lifecycle {
    ignore_changes = ["final_snapshot_identifier"]
  }
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count                = "${var.amount_of_instances}"
  identifier           = "${var.project}-${var.environment}${var.tag}-aurora${count.index}"
  cluster_identifier   = "${aws_rds_cluster.aurora.id}"
  instance_class       = "${var.size}"
  db_subnet_group_name = "${aws_db_subnet_group.aurora.id}"
  apply_immediately    = "${var.apply_immediately}"
  db_parameter_group_name = "${var.instance_parameter_group_name == "" ? aws_db_parameter_group.aurora_mysql.id : var.instance_parameter_group_name}"

  tags {
    Name        = "${var.project}-${var.environment}${var.tag}-aurora${count.index}"
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }
}
