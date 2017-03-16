variable "security_groups" {
  description = "Security groups that are allowed to access the RDS on port 3306"
  type        = "list"
}

variable "subnets" {
  type        = "list"
  description = "Subnets to deploy in"
}

variable "size" {
  description = "Instance size"
  default     = "db.t2.small"
}

variable "password" {
  description = "RDS root password"
}

variable "backup_retention_period" {
  description = "How long do you want to keep RDS backups"
  default     = "14"
}

variable "apply_immediately" {
  description = "Apply changes immediately"
  default     = true
}

variable "storage_encrypted" {
  description = "Encrypt RDS storage"
  default     = true
}

variable "environment" {
  description = "How do you want to call your environment, this is helpful if you have more than 1 VPC."
  default     = "production"
}

variable "project" {
  description = "The current project"
  default     = ""
}

variable "tag" {
  description = "A tag used to identify an RDS in a project that has more than one RDS"
  default     = ""
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot when destroying RDS"
  default     = false
}

variable "amount_of_instances" {
  description = "The amount of Aurora instances you need, for HA you need minumum 2"
  default     = 1
}

variable "rds_parameter_group_name" {
  description = "Optional parameter group you can set for the RDS cluster "
  default = ""
}
