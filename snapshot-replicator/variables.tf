variable "aws_source_region" {
  default = "eu-west-1"
}

variable "aws_destination_region" {
  default = "eu-central-1"
}

variable "db_instances" {
  type    = "list"
  default = []
}

variable "kms_key_id" {
  default = ""
}

variable "provider" {
  default = ""
}

variable "enable" {
}

variable "retention" {
  default = ""
}
