variable "security_groups" {
  description = "Security groups that are allowed to access the RDS on port 3306"
  type        = list(string)
}

variable "subnets" {
  type        = list(string)
  description = "Subnets to deploy in"
}

variable "size" {
  description = "Instance size"
  default     = "db.t2.small"
}

variable "instance_size_override" {
  description = "Provide different instance sizes for each individual aurora instance in the cluster. The size of the list must be equal to `var.amount_of_instances`. If ommitted or set to [], this module will use `var.size` for all the instances in the cluster."
  type        = list(string)
  default     = []
}

variable "instance_promotion_tiers" {
  description = "Set promotion tier for each instance in the cluster. The size of the list must be equal to `var.amount_of_instances`. If ommitted or set to [], the default of 0 will be used."
  type        = list(number)
  default     = []
}

variable "password" {
  description = "RDS root password"
}

variable "rds_username" {
  description = "RDS root user"
  default     = "root"
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

variable "cluster_parameter_group_name" {
  description = "Optional parameter group you can set for the RDS Aurora cluster "
  default     = ""
}

variable "instance_parameter_group_name" {
  description = "Optional parameter group you can set for the RDS instances inside an Aurora cluster "
  default     = ""
}

variable "engine" {
  description = "Optional parameter to set the Aurora engine "
  default     = "aurora"
}

variable "engine_version" {
  description = "Optional parameter to set the Aurora engine version"
  default     = "5.6.10a"
}

variable "family" {
  default = "aurora5.6"
}

variable "default_ports" {
  default = {
    aurora            = "3306"
    aurora-postgresql = "5432"
  }
}

variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to enable for exporting to CloudWatch logs. You can check the available log types per engine in the [AWS Aurora documentation](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/USER_LogAccess.html#USER_LogAccess.Procedural.UploadtoCloudWatch)."
  type        = list(string)
  default     = []
}

variable "performance_insights_enabled" {
  description = "Specifies whether Performance Insights is enabled or not."
  type        = bool
  default     = false
}

variable "rds_instance_name_overrides" {
  description = "List of names to override the default RDS instance names / identifiers."
  type        = list(string)
  default     = null
}

variable "snapshot_identifier" {
  description = "Specifies whether or not to create this cluster from a snapshot. You can use either the name or ARN when specifying a DB cluster snapshot, or the ARN when specifying a DB snapshot"
  type        = string
  default     = null
}

variable "extra_tags" {
  description = "A mapping of extra tags to assign to the resource"
  type        = map(string)
  default     = {}
}
