resource "aws_db_subnet_group" "rds" {
  count       = "${var.number_of_replicas > 0 ? 1 : 0}"
  name        = "${length(var.name) == 0 ? "${var.project}-${var.environment}${var.tag}-rds-replica" : var.name}"
  description = "The group of subnets"
  subnet_ids  = ["${var.subnets}"]
}

data "aws_db_instance" "master" {
  db_instance_identifier = "${var.replicate_source_db}"
}

resource "aws_db_instance" "rds" {
  count                  = "${var.number_of_replicas}"
  identifier             = "${length(var.name) == 0 ? "${var.project}-${var.environment}${var.tag}-rds${count.index+1}-replica" : var.name}"
  engine                 = "${var.engine}"
  instance_class         = "${var.size}"
  vpc_security_group_ids = ["${aws_security_group.sg_rds.0.id}"]
  replicate_source_db    = "${var.replicate_source_db}"
  db_subnet_group_name   = "${aws_db_subnet_group.rds.0.id}"
  storage_encrypted      = "${var.storage_encrypted}"
  parameter_group_name   = "${var.custom_parameter_group_name == "" ? data.aws_db_instance.master.db_parameter_groups[0] : var.custom_parameter_group_name}"

  tags {
    Name        = "${length(var.name) == 0 ? "${var.project}-${var.environment}${var.tag}-rds${count.index+1}-replica" : var.name}"
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }

  lifecycle {
    ignore_changes = ["replicate_source_db"]
  }
}
