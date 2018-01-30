variable "vpc_id" {
  description = "ID of the VPC where to deploy in"
}

variable "security_groups" {
  description = "Security groups that are allowed to access the RDS"
  type        = "list"
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks that are allowed to access the RDS"
  type        = "list"
  default     = []
}

variable "subnets" {
  type        = "list"
  description = "Subnets to deploy in"
}

variable "storage" {
  description = "How many GBs of space does your database need?"
  default     = "10"
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
  default = "root"
}

variable "engine" {
  description = "RDS engine: mysql, oracle, postgres. Defaults to mysql"
  default     = "mysql"
}

variable "engine_version" {
  description = "Engine version to use, according to the chosen engine. You can check the available engine versions using the AWS CLI (http://docs.aws.amazon.com/cli/latest/reference/rds/describe-db-engine-versions.html). Defaults to 5.7.17 for MySQL."
  default     = "5.7.17"
}

variable "default_parameter_group_family" {
  description = "Parameter group family for the default parameter group, according to the chosen engine and engine version. Will be omitted if `rds_custom_parameter_group_name` is provided. Defaults to mysql5.7"
  default     = "mysql5.7"
}

variable "replicate_source_db" {
  description = "RDS source to replicate from"
  default     = ""
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
  description = "A custom parameter group name to attach to the RDS instance. If not provided a default one will be created"
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
