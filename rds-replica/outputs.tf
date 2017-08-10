output "rds_address" {
  value = "${aws_db_instance.rds.address}"
}

output "rds_arn" {
  value = "${aws_db_instance.rds.arn}"
}

output "rds_sg_id" {
  value = "${aws_security_group.sg_rds.id}"
}
