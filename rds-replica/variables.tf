variable "vpc_id" {
  description = "ID of the VPC where to deploy in"
}

variable "project" {
  description = "The current project"
  default     = ""
}

variable "engine" {
}

variable "security_groups" {
  description = "Security groups that are allowed to access the RDS"
  type        = list(string)
  default     = []
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

variable "size" {
  description = "Instance size"
  default     = "db.t2.small"
}

variable "replicate_source_db" {
  description = "RDS source to replicate from"
  default     = ""
}

variable "environment" {
  description = "How do you want to call your environment, this is helpful if you have more than 1 VPC."
  default     = "production"
}

variable "tag" {
  description = "A tag used to identify an RDS in a project that has more than one RDS"
  default     = ""
}

variable "number_of_replicas" {
  description = "number of database repliacs default 1"
  default     = 1
}

variable "name" {
  description = "An optional custom name to give to the module's resources"
  default     = ""
}

variable "storage_encrypted" {
  description = "Encrypt RDS storage"
  default     = true
}

variable "custom_parameter_group_name" {
  description = "A custom parameter group name to attach to the RDS instance. If not provided it will use the default from the master instance"
  default     = ""
}

variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to enable for exporting to CloudWatch logs. You can check the available log types per engine in the [AWS RDS documentation](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_LogAccess.html#USER_LogAccess.Procedural.UploadtoCloudWatch)."
  type        = list(string)
  default     = []
}

variable "backup_retention_period" {
  description = "How long do you want to keep RDS Slave backups"
  default     = "14"
}
