variable "aws_source_region" {
  default = "eu-west-1"
}

variable "aws_destination_region" {
  default = "eu-central-1"
}

variable "db_instances" {
  type    = list(string)
  default = []
}

variable "kms_key_id" {
  default = ""
}

variable "enable" {
  default = false
}

variable "retention" {
  default = 25
}

variable "environment" {
}

variable "custom_snapshot_rate" {
  type        = number
  default     = 6
  description = "Number of hours to take custom RDS snapshots every each"
}

variable "sns_topic_arn" {
  type        = string
  description = "ARN of SNS topic to use for monitoring of the snapshot creation, copy, and cleanup process"
}

