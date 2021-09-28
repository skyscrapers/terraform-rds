variable "name" {
  description = "Name of the setup"
  type        = string
}

variable "rds_instance_ids" {
  description = "List of IDs of the RDS instances to back up"
  type        = list(string)
}

variable "snapshot_interval" {
  description = "Snapshot frequency in hours"
  type        = number
  default     = 6
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
