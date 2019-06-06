output "rds_address" {
  value = aws_db_instance.rds.*.address
}

output "rds_arn" {
  value = aws_db_instance.rds.*.arn
}

output "rds_sg_id" {
  # trick to allow correct module behaviour in case number_of_replicas=0
  value = element(coalescelist(aws_security_group.sg_rds.*.id, ["none"]), 0)
}

