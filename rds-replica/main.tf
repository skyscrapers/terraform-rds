resource "aws_db_instance" "rds" {
  identifier                = "replica-${var.environment}-${var.name}-rds${var.number}"
  engine                    = "${var.engine}"
  instance_class            = "${var.size}"
  vpc_security_group_ids    = ["${aws_security_group.sg_rds.id}"]
  replicate_source_db       = "${var.replicate_source_db}"
  availability_zone         = "${var.availability_zone}"
  final_snapshot_identifier = "${var.project}-${var.environment}${var.name}-rds${var.number}-final-${md5(timestamp())}"

  tags {
    Name        = "replica-${var.environment}-${var.name}-rds${var.number}"
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }
  lifecycle {
    ignore_changes = ["final_snapshot_identifier"]
  }
}
