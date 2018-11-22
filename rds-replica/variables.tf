variable "vpc_id" {
  description = "ID of the VPC where to deploy in"
}

variable "project" {
  description = "The current project"
  default     = ""
}

variable "engine" {}

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
  default = ""
}

variable "storage_encrypted" {
  description = "Encrypt RDS storage"
  default     = true
}

variable "custom_parameter_group_name" {
  description = "A custom parameter group name to attach to the RDS instance. If not provided it will use the default from the master instance"
  default = ""
}
