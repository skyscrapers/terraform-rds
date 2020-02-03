output "aurora_cluster_id" {
  value = "${aws_rds_cluster.aurora.id}"
}

output "aurora_cluster_instances_id" {
  value = "${aws_rds_cluster_instance.cluster_instances.*.id}"
}

output "aurora_port" {
  value = "${local.port}"
}

output "aurora_sg_id" {
  value = "${aws_security_group.sg_aurora.id}"
}

output "endpoint" {
  value = "${aws_rds_cluster.aurora.endpoint}"
}

output "reader_endpoint" {
  value = "${aws_rds_cluster.aurora.reader_endpoint}"
}
