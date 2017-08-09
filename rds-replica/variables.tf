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

variable "size" {
  description = "Instance size"
  default     = "db.t2.small"
}

variable "rds_type" {
  description = "RDS type: mysql, oracle, postgres"
  default     = "mysql"
}

variable "replicate_source_db" {
  description = "RDS source to replicate from"
  default     = ""
}

variable "environment" {
  description = "How do you want to call your environment, this is helpful if you have more than 1 VPC."
  default     = "production"
}

variable "name" {
  description = "A name used to identify an RDS in a project that has more than one RDS"
  default     = ""
}

variable "number" {
  description = "number of the database default 01"
  default     = "01"
}

variable "availability_zone" {
  default = ""
}
