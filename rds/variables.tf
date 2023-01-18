variable "vpc_id" {
  description = "ID of the VPC where to deploy in"
}

variable "security_groups" {
  description = "Security groups that are allowed to access the RDS"
  type        = list(string)
}

variable "security_groups_count" {
  description = "Number of security groups provided in `security_groups` variable"
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks that are allowed to access the RDS"
  type        = list(string)
  default     = []
}

variable "subnets" {
  type        = list(string)
  description = "Subnets to deploy in"
}

variable "storage" {
  description = "How many GBs of space does your database need?"
  default     = "10"
}

variable "max_allocated_storage" {
  description = "When configured, the upper limit to which Amazon RDS can automatically scale the storage of the DB instance. Configuring this will automatically ignore differences to allocated_storage. Must be greater than or equal to allocated_storage or 0 to disable Storage Autoscaling."
  type        = string
  default     = "0"
}

variable "size" {
  description = "Instance size"
  default     = "db.t2.small"
}

variable "storage_type" {
  description = "Type of storage you want to use"
  default     = "gp2"
}

variable "rds_password" {
  description = "RDS root password"
}

variable "rds_username" {
  description = "RDS root user"
  default     = "root"
}

variable "engine" {
  description = "RDS engine: mysql, oracle, postgres. Defaults to mysql"
  default     = "mysql"
}

variable "engine_version" {
  description = "Engine version to use, according to the chosen engine. You can check the available engine versions using the [AWS CLI](http://docs.aws.amazon.com/cli/latest/reference/rds/describe-db-engine-versions.html). Defaults to 5.7.17 for MySQL."
  default     = "5.7.25"
}

variable "default_parameter_group_family" {
  description = "Parameter group family for the default parameter group, according to the chosen engine and engine version. Defaults to mysql5.7"
  default     = "mysql5.7"
}

variable "multi_az" {
  description = "Multi AZ true or false"
  default     = true
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

variable "storage_kms_key_id" {
  description = "Custom KMS key to use to encrypt the storage. Will use the AWS key if left null (default)"
  type        = string
  default     = null
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

variable "number" {
  description = "number of the database default 01"
  default     = "01"
}

variable "rds_custom_parameter_group_name" {
  description = "A custom parameter group name to attach to the RDS instance. If not provided a default one will be used"
  default     = ""
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot when destroying RDS"
  default     = false
}

variable "availability_zone" {
  description = "The availability zone where you want to launch your instance in"
  default     = ""
}

variable "snapshot_identifier" {
  description = "Specifies whether or not to create this database from a snapshot. This correlates to the snapshot ID you'd find in the RDS console, e.g: rds:production-2015-06-26-06-05."
  default     = ""
}

variable "name" {
  description = "The name of the RDS instance"
  default     = ""
}

variable "subnet_group_name_override" {
  type        = string
  description = "Override the name of the created subnet group"
  default     = null
}

variable "monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. Valid Values: 0, 1, 5, 10, 15, 30, 60."
  default     = "0"
}

variable "auto_minor_version_upgrade" {
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window."
  default     = true
}

variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to enable for exporting to CloudWatch logs. You can check the available log types per engine in the [AWS RDS documentation](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_LogAccess.html#USER_LogAccess.Procedural.UploadtoCloudWatch)."
  type        = list(string)
  default     = []
}

variable "performance_insights_enabled" {
  description = "Specifies whether Performance Insights is enabled or not."
  type        = bool
  default     = false
}

variable "performance_insights_kms_key_id" {
  description = "Custom KMS key to use to encrypt the performance insights data"
  type        = string
  default     = null
}

variable "performance_insights_retention_period" {
  description = "Amount of time in days to retain Performance Insights data. Valid values are 7, 731 (2 years) or a multiple of 31. When specifying performance_insights_retention_period"
  default     = 7
}

variable "extra_tags" {
  description = "A mapping of extra tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "deletion_protection" {
  description = "If the DB instance should have deletion protection enabled. The database can't be deleted when this value is set to true"
  type        = bool
  default     = false
}

variable "publicly_accessible" {
  description = "Bool to control if instance is publicly accessible"
  type        = bool
  default     = false
}

variable "maintenance_window" {
  description = "The window to perform maintenance in. Syntax: \"ddd:hh24:mi-ddd:hh24:mi\". Eg: \"Mon:00:00-Mon:03:00\""
  type        = string
  default     = null
}
