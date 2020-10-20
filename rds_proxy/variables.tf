
variable "security_groups" {
  description = "Security groups that are allowed to access the RDS"
  type        = list(string)
}

variable "subnets" {
  type        = list(string)
  description = "Subnets to deploy in"
}

variable "environment" {
  description = "The current environment"
  default     = terraform.workspace
}

variable "project" {
  description = "The current project"
}

variable "engine" {
  description = "RDS engine: mysql, oracle, postgres. Defaults to mysql"
}

