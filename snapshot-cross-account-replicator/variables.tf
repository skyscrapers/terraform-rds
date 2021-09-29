variable "name" {
  description = "Name of the setup"
  type        = string
}

variable "rds_instance_ids" {
  description = "List of IDs of the RDS instances to back up"
  type        = list(string)
}

variable "snapshot_schedule_expression" {
  description = "Snapshot frequency specified as a CloudWatch schedule expression. Can either be a `rate()` or `cron()` expression. Check the [AWS documentation](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html#CronExpressions) on how to compose such expression."
  type        = string
  default     = "cron(0 */6 * * ? *)"
}

variable "retention_period" {
  description = "Snapshot retention period in days"
  type        = number
  default     = 25
}

variable "target_account_kms_key_id" {
  description = "KMS key to use to encrypt replicated RDS snapshots in the target AWS account"
  type        = string
}
