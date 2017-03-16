output "aurora_port" {
  value = "3306"
}

output "aurora_sg_id" {
  value = "${aws_security_group.sg_aurora.id}"
}
