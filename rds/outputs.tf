output "rds_port" {
  description = "The port of the RDS instance"
  value       = local.port
}

output "rds_address" {
  description = "The hostname of the RDS instance"
  value       = aws_db_instance.rds.address
}

output "rds_id" {
  description = "The id of the RDS instance"
  value       = aws_db_instance.rds.id
}

output "rds_arn" {
  description = "The arn of the RDS instance"
  value       = aws_db_instance.rds.arn
}

output "rds_sg_id" {
  description = "The security group id of the RDS instance"
  value       = aws_security_group.sg_rds.id
}

output "aws_db_subnet_group_id" {
  description = "The subnet group id of the RDS instance"
  value       = aws_db_subnet_group.rds.id
}

