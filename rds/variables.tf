variable "vpc_id" {
  description = "ID of the VPC where to deploy in"
}

variable "security_groups" {
  description = "Security groups that are allowed to access the RDS on port 3306"
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
  default     = "standard"
}

variable "rds_password" {
  description = "RDS root password"
}

variable "rds_type" {
  description = "RDS type: mysql, oracle"
  default     = "mysql"
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
  default = "01"
}


variable "rds_parameter_group_name" {
  default = ""
}
