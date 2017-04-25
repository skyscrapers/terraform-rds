output "rds_port" {
  value = "${lookup(var.ports, var.rds_type)}"
}

output "rds_address" {
  value = "${aws_db_instance.rds.address}"
}

output "rds_arn" {
  value = "${aws_db_instance.rds.arn}"
}

output "rds_sg_id" {
  value = "${aws_security_group.sg_rds.id}"
}

output "aws_db_subnet_group_id" {
  value = "${aws_db_subnet_group.rds.id}"
}
