output "rds_port" {
  value = "${lookup(var.ports, var.rds_type)}"
}

output "rds_arn" {
  value = "${aws_db_instance.rds.arn}"
}
