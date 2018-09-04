resource "aws_db_subnet_group" "rds" {
  name        = "${length(var.name) == 0 ? "${var.project}-${var.environment}${var.tag}-rds${var.number}-replica" : var.name}"
  description = "The group of subnets"
  subnet_ids  = ["${var.subnets}"]
}

resource "aws_db_instance" "rds" {
  identifier                = "${length(var.name) == 0 ? "${var.project}-${var.environment}${var.tag}-rds${var.number}-replica" : var.name}"
  engine                    = "${var.engine}"
  instance_class            = "${var.size}"
  vpc_security_group_ids    = ["${aws_security_group.sg_rds.id}"]
  replicate_source_db       = "${var.replicate_source_db}"
  db_subnet_group_name      = "${aws_db_subnet_group.rds.id}"
  storage_encrypted         = "${var.storage_encrypted}"

  tags {
    Name        = "${length(var.name) == 0 ? "${var.project}-${var.environment}${var.tag}-rds${var.number}-replica" : var.name}"
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }

  lifecycle {
    ignore_changes = ["replicate_source_db"]
  }
}
