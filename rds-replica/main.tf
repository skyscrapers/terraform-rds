resource "aws_db_instance" "rds" {
  identifier                = "${var.project}-${var.environment}${var.name}-rds${var.number}-replica"
  engine                    = "${var.engine}"
  instance_class            = "${var.size}"
  vpc_security_group_ids    = ["${aws_security_group.sg_rds.id}"]
  replicate_source_db       = "${var.replicate_source_db}"
  final_snapshot_identifier = "${var.project}-${var.environment}${var.name}-rds${var.number}-final-${md5(timestamp())}"
  db_subnet_group_name      = "${var.db_subnet_group_name}"

  tags {
    Name        = "replica-${var.environment}-${var.name}-rds${var.number}"
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }
  lifecycle {
    ignore_changes = ["final_snapshot_identifier","replicate_source_db"]
  }
}
