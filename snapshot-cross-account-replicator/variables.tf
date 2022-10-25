variable "name" {
  description = "Name of the setup"
  type        = string
}

variable "is_aurora_cluster" {
  description = "Whether we're backing up Aurora clusters instead of RDS instances"
  type        = bool
  default     = false
}

variable "rds_instance_ids" {
  description = "List of IDs of the RDS instances to back up. If using Aurora, provide the cluster IDs instead"
  type        = list(string)
}

variable "snapshot_schedule_period" {
  description = "Snapshot frequency specified in hours"
  type        = number
  default     = 6
}

variable "retention_period" {
  description = "Snapshot retention period in days"
  type        = number
  default     = 14
}

variable "target_account_kms_key_id" {
  description = "KMS key to use to encrypt replicated RDS snapshots in the target AWS account"
  type        = string
}
