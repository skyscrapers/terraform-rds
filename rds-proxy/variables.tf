
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
}

variable "project" {
  description = "The current project"
}

variable "engine" {
  description = "RDS engine: MYSQL or POSTGRESQL"
}

variable "db_secret_arns" {
  description = "AWS Secret Manager ARNs to use to access the database credentials"
  type        = list(any)
}

variable "db_cluster_identifier" {
  description = "ID of the database cluster to set as the proxy target"
}

variable "proxy_connection_timeout" {
  description = "The number of seconds for a proxy to wait for a connection to become available in the connection pool"
  type        = number
  default     = 120
}

variable "proxy_max_connection_percent" {
  description = "The maximum size of the connection pool for each target in a target group"
  type        = number
  default     = 100
}

variable "extra_tags" {
  description = "A mapping of extra tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "idle_client_timeout" {
  description = "The number of seconds that a connection to the proxy can be inactive before the proxy disconnects it. You can set this value higher or lower than the connection timeout limit for the associated database."
  type        = number
  default     = 1800
}

variable "debug_logging" {
  description = "Whether the proxy includes detailed information about SQL statements in its logs. This information helps you to debug issues involving SQL behavior or the performance and scalability of the proxy connections."
  type        = bool
  default     = false
}

variable "reader_endpoint" {
  description = "Whether to include an extra reader endpoint."
  type        = bool
  default     = false
}
