# terraform-rds

Terraform modules to manage RDS resources

## rds

Creates a RDS instance, security_group, subnet_group and parameter_group

### Requirements

| Name                                                                      | Version |
| ------------------------------------------------------------------------- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12 |

### Providers

| Name                                              | Version |
| ------------------------------------------------- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a     |

### Modules

No modules.

### Resources

| Name                                                                                                                                   | Type     |
| -------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_db_instance.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance)                         | resource |
| [aws_db_parameter_group.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group)           | resource |
| [aws_db_subnet_group.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group)                 | resource |
| [aws_security_group.sg_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)                | resource |
| [aws_security_group_rule.rds_cidr_in](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.rds_sg_in](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule)   | resource |

### Inputs

| Name                                                                                                                                                    | Description                                                                                                                                                                                                                                                                         | Type           | Default         | Required |
| ------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | --------------- | :------: |
| <a name="input_rds_password"></a> [rds\_password](#input\_rds\_password)                                                                                | RDS root password                                                                                                                                                                                                                                                                   | `any`          | n/a             |   yes    |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups)                                                                       | Security groups that are allowed to access the RDS                                                                                                                                                                                                                                  | `list(string)` | n/a             |   yes    |
| <a name="input_security_groups_count"></a> [security\_groups\_count](#input\_security\_groups\_count)                                                   | Number of security groups provided in `security_groups` variable                                                                                                                                                                                                                    | `any`          | n/a             |   yes    |
| <a name="input_subnets"></a> [subnets](#input\_subnets)                                                                                                 | Subnets to deploy in                                                                                                                                                                                                                                                                | `list(string)` | n/a             |   yes    |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id)                                                                                                  | ID of the VPC where to deploy in                                                                                                                                                                                                                                                    | `any`          | n/a             |   yes    |
| <a name="input_allowed_cidr_blocks"></a> [allowed\_cidr\_blocks](#input\_allowed\_cidr\_blocks)                                                         | CIDR blocks that are allowed to access the RDS                                                                                                                                                                                                                                      | `list(string)` | `[]`            |    no    |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately)                                                                 | Apply changes immediately                                                                                                                                                                                                                                                           | `bool`         | `true`          |    no    |
| <a name="input_auto_minor_version_upgrade"></a> [auto\_minor\_version\_upgrade](#input\_auto\_minor\_version\_upgrade)                                  | Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window.                                                                                                                                                                | `bool`         | `true`          |    no    |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone)                                                                 | The availability zone where you want to launch your instance in                                                                                                                                                                                                                     | `string`       | `""`            |    no    |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period)                                             | How long do you want to keep RDS backups                                                                                                                                                                                                                                            | `string`       | `"14"`          |    no    |
| <a name="input_default_parameter_group_family"></a> [default\_parameter\_group\_family](#input\_default\_parameter\_group\_family)                      | Parameter group family for the default parameter group, according to the chosen engine and engine version. Defaults to mysql5.7                                                                                                                                                     | `string`       | `"mysql5.7"`    |    no    |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection)                                                           | If the DB instance should have deletion protection enabled. The database can't be deleted when this value is set to true                                                                                                                                                            | `bool`         | `false`         |    no    |
| <a name="input_enabled_cloudwatch_logs_exports"></a> [enabled\_cloudwatch\_logs\_exports](#input\_enabled\_cloudwatch\_logs\_exports)                   | List of log types to enable for exporting to CloudWatch logs. You can check the available log types per engine in the [AWS RDS documentation](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_LogAccess.html#USER_LogAccess.Procedural.UploadtoCloudWatch).             | `list(string)` | `[]`            |    no    |
| <a name="input_engine"></a> [engine](#input\_engine)                                                                                                    | RDS engine: mysql, oracle, postgres. Defaults to mysql                                                                                                                                                                                                                              | `string`       | `"mysql"`       |    no    |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version)                                                                          | Engine version to use, according to the chosen engine. You can check the available engine versions using the [AWS CLI](http://docs.aws.amazon.com/cli/latest/reference/rds/describe-db-engine-versions.html). Defaults to 5.7.17 for MySQL.                                         | `string`       | `"5.7.25"`      |    no    |
| <a name="input_environment"></a> [environment](#input\_environment)                                                                                     | How do you want to call your environment, this is helpful if you have more than 1 VPC.                                                                                                                                                                                              | `string`       | `"production"`  |    no    |
| <a name="input_extra_tags"></a> [extra\_tags](#input\_extra\_tags)                                                                                      | A mapping of extra tags to assign to the resource                                                                                                                                                                                                                                   | `map(string)`  | `{}`            |    no    |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window)                                                              | The window to perform maintenance in. Syntax: "ddd:hh24:mi-ddd:hh24:mi". Eg: "Mon:00:00-Mon:03:00"                                                                                                                                                                                  | `string`       | `null`          |    no    |
| <a name="input_max_allocated_storage"></a> [max\_allocated\_storage](#input\_max\_allocated\_storage)                                                   | When configured, the upper limit to which Amazon RDS can automatically scale the storage of the DB instance. Configuring this will automatically ignore differences to allocated\_storage. Must be greater than or equal to allocated\_storage or 0 to disable Storage Autoscaling. | `string`       | `"0"`           |    no    |
| <a name="input_monitoring_interval"></a> [monitoring\_interval](#input\_monitoring\_interval)                                                           | The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. Valid Values: 0, 1, 5, 10, 15, 30, 60.                                                                   | `string`       | `"0"`           |    no    |
| <a name="input_multi_az"></a> [multi\_az](#input\_multi\_az)                                                                                            | Multi AZ true or false                                                                                                                                                                                                                                                              | `bool`         | `true`          |    no    |
| <a name="input_name"></a> [name](#input\_name)                                                                                                          | The name of the RDS instance                                                                                                                                                                                                                                                        | `string`       | `""`            |    no    |
| <a name="input_number"></a> [number](#input\_number)                                                                                                    | number of the database default 01                                                                                                                                                                                                                                                   | `string`       | `"01"`          |    no    |
| <a name="input_performance_insights_enabled"></a> [performance\_insights\_enabled](#input\_performance\_insights\_enabled)                              | Specifies whether Performance Insights is enabled or not.                                                                                                                                                                                                                           | `bool`         | `false`         |    no    |
| <a name="input_performance_insights_kms_key_id"></a> [performance\_insights\_kms\_key\_id](#input\_performance\_insights\_kms\_key\_id)                 | Custom KMS key to use to encrypt the performance insights data                                                                                                                                                                                                                      | `string`       | `null`          |    no    |
| <a name="input_performance_insights_retention_period"></a> [performance\_insights\_retention\_period](#input\_performance\_insights\_retention\_period) | Amount of time in days to retain Performance Insights data. Valid values are 7, 731 (2 years) or a multiple of 31. When specifying performance\_insights\_retention\_period                                                                                                         | `number`       | `7`             |    no    |
| <a name="input_project"></a> [project](#input\_project)                                                                                                 | The current project                                                                                                                                                                                                                                                                 | `string`       | `""`            |    no    |
| <a name="input_publicly_accessible"></a> [publicly\_accessible](#input\_publicly\_accessible)                                                           | Bool to control if instance is publicly accessible                                                                                                                                                                                                                                  | `bool`         | `false`         |    no    |
| <a name="input_rds_custom_parameter_group_name"></a> [rds\_custom\_parameter\_group\_name](#input\_rds\_custom\_parameter\_group\_name)                 | A custom parameter group name to attach to the RDS instance. If not provided a default one will be used                                                                                                                                                                             | `string`       | `""`            |    no    |
| <a name="input_rds_username"></a> [rds\_username](#input\_rds\_username)                                                                                | RDS root user                                                                                                                                                                                                                                                                       | `string`       | `"root"`        |    no    |
| <a name="input_size"></a> [size](#input\_size)                                                                                                          | Instance size                                                                                                                                                                                                                                                                       | `string`       | `"db.t2.small"` |    no    |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot)                                                         | Skip final snapshot when destroying RDS                                                                                                                                                                                                                                             | `bool`         | `false`         |    no    |
| <a name="input_snapshot_identifier"></a> [snapshot\_identifier](#input\_snapshot\_identifier)                                                           | Specifies whether or not to create this database from a snapshot. This correlates to the snapshot ID you'd find in the RDS console, e.g: rds:production-2015-06-26-06-05.                                                                                                           | `string`       | `""`            |    no    |
| <a name="input_storage"></a> [storage](#input\_storage)                                                                                                 | How many GBs of space does your database need?                                                                                                                                                                                                                                      | `string`       | `"10"`          |    no    |
| <a name="input_storage_encrypted"></a> [storage\_encrypted](#input\_storage\_encrypted)                                                                 | Encrypt RDS storage                                                                                                                                                                                                                                                                 | `bool`         | `true`          |    no    |
| <a name="input_storage_kms_key_id"></a> [storage\_kms\_key\_id](#input\_storage\_kms\_key\_id)                                                          | Custom KMS key to use to encrypt the storage. Will use the AWS key if left null (default)                                                                                                                                                                                           | `string`       | `null`          |    no    |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type)                                                                                | Type of storage you want to use                                                                                                                                                                                                                                                     | `string`       | `"gp2"`         |    no    |
| <a name="input_subnet_group_name_override"></a> [subnet\_group\_name\_override](#input\_subnet\_group\_name\_override)                                  | Override the name of the created subnet group                                                                                                                                                                                                                                       | `string`       | `null`          |    no    |
| <a name="input_tag"></a> [tag](#input\_tag)                                                                                                             | A tag used to identify an RDS in a project that has more than one RDS                                                                                                                                                                                                               | `string`       | `""`            |    no    |

### Outputs

| Name                                                                                                           | Description                               |
| -------------------------------------------------------------------------------------------------------------- | ----------------------------------------- |
| <a name="output_aws_db_subnet_group_id"></a> [aws\_db\_subnet\_group\_id](#output\_aws\_db\_subnet\_group\_id) | The subnet group id of the RDS instance   |
| <a name="output_rds_address"></a> [rds\_address](#output\_rds\_address)                                        | The hostname of the RDS instance          |
| <a name="output_rds_arn"></a> [rds\_arn](#output\_rds\_arn)                                                    | The arn of the RDS instance               |
| <a name="output_rds_id"></a> [rds\_id](#output\_rds\_id)                                                       | The id of the RDS instance                |
| <a name="output_rds_port"></a> [rds\_port](#output\_rds\_port)                                                 | The port of the RDS instance              |
| <a name="output_rds_sg_id"></a> [rds\_sg\_id](#output\_rds\_sg\_id)                                            | The security group id of the RDS instance |

### Example

```tf
module "rds" {
  source                          = "github.com/skyscrapers/terraform-rds//rds"
  vpc_id                          = "vpc-e123bc45"
  subnets                         = ["subnet-12345d67", "subnet-12345d68", "subnet-12345d69"]
  project                         = "myproject"
  environment                     = "production"
  size                            = "db.t2.small"
  security_groups                 = ["sg-12be345678905ebf1", "sg-1234567890aef"]
  enabled_cloudwatch_logs_exports = ["audit", "error", "slowquery"]
  security_groups_count           = 2
  rds_password                    = "supersecurepassword"
  multi_az                        = "false"
}
```

## Aurora

Creates a Aurora cluster + instances, security_group, subnet_group and parameter_group

### Requirements

| Name                                                                      | Version |
| ------------------------------------------------------------------------- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12 |

### Providers

| Name                                              | Version |
| ------------------------------------------------- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a     |

### Modules

No modules.

### Resources

| Name                                                                                                                                           | Type        |
| ---------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_db_parameter_group.aurora_mysql](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group)          | resource    |
| [aws_db_subnet_group.aurora](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group)                      | resource    |
| [aws_rds_cluster.aurora](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster)                              | resource    |
| [aws_rds_cluster_instance.cluster_instances](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_instance) | resource    |
| [aws_security_group.sg_aurora](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)                     | resource    |
| [aws_security_group_rule.sg_aurora_in](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule)        | resource    |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones)          | data source |
| [aws_subnet.subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet)                                     | data source |

### Inputs

| Name                                                                                                                                  | Description                                                                                                                                                                                                                                                                      | Type           | Default                                                                   | Required |
| ------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ------------------------------------------------------------------------- | :------: |
| <a name="input_password"></a> [password](#input\_password)                                                                            | RDS root password                                                                                                                                                                                                                                                                | `any`          | n/a                                                                       |   yes    |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups)                                                     | Security groups that are allowed to access the RDS on port 3306                                                                                                                                                                                                                  | `list(string)` | n/a                                                                       |   yes    |
| <a name="input_subnets"></a> [subnets](#input\_subnets)                                                                               | Subnets to deploy in                                                                                                                                                                                                                                                             | `list(string)` | n/a                                                                       |   yes    |
| <a name="input_amount_of_instances"></a> [amount\_of\_instances](#input\_amount\_of\_instances)                                       | The amount of Aurora instances you need, for HA you need minumum 2                                                                                                                                                                                                               | `number`       | `1`                                                                       |    no    |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately)                                               | Apply changes immediately                                                                                                                                                                                                                                                        | `bool`         | `true`                                                                    |    no    |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period)                           | How long do you want to keep RDS backups                                                                                                                                                                                                                                         | `string`       | `"14"`                                                                    |    no    |
| <a name="input_cluster_parameter_group_name"></a> [cluster\_parameter\_group\_name](#input\_cluster\_parameter\_group\_name)          | Optional parameter group you can set for the RDS Aurora cluster                                                                                                                                                                                                                  | `string`       | `""`                                                                      |    no    |
| <a name="input_default_ports"></a> [default\_ports](#input\_default\_ports)                                                           | n/a                                                                                                                                                                                                                                                                              | `map`          | <pre>{<br>  "aurora": "3306",<br>  "aurora-postgresql": "5432"<br>}</pre> |    no    |
| <a name="input_enabled_cloudwatch_logs_exports"></a> [enabled\_cloudwatch\_logs\_exports](#input\_enabled\_cloudwatch\_logs\_exports) | List of log types to enable for exporting to CloudWatch logs. You can check the available log types per engine in the [AWS Aurora documentation](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/USER_LogAccess.html#USER_LogAccess.Procedural.UploadtoCloudWatch). | `list(string)` | `[]`                                                                      |    no    |
| <a name="input_engine"></a> [engine](#input\_engine)                                                                                  | Optional parameter to set the Aurora engine                                                                                                                                                                                                                                      | `string`       | `"aurora"`                                                                |    no    |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version)                                                        | Optional parameter to set the Aurora engine version                                                                                                                                                                                                                              | `string`       | `"5.6.10a"`                                                               |    no    |
| <a name="input_environment"></a> [environment](#input\_environment)                                                                   | How do you want to call your environment, this is helpful if you have more than 1 VPC.                                                                                                                                                                                           | `string`       | `"production"`                                                            |    no    |
| <a name="input_extra_tags"></a> [extra\_tags](#input\_extra\_tags)                                                                    | A mapping of extra tags to assign to the resource                                                                                                                                                                                                                                | `map(string)`  | `{}`                                                                      |    no    |
| <a name="input_family"></a> [family](#input\_family)                                                                                  | n/a                                                                                                                                                                                                                                                                              | `string`       | `"aurora5.6"`                                                             |    no    |
| <a name="input_instance_parameter_group_name"></a> [instance\_parameter\_group\_name](#input\_instance\_parameter\_group\_name)       | Optional parameter group you can set for the RDS instances inside an Aurora cluster                                                                                                                                                                                              | `string`       | `""`                                                                      |    no    |
| <a name="input_instance_promotion_tiers"></a> [instance\_promotion\_tiers](#input\_instance\_promotion\_tiers)                        | Set promotion tier for each instance in the cluster. The size of the list must be equal to `var.amount_of_instances`. If ommitted or set to [], the default of 0 will be used.                                                                                                   | `list(number)` | `[]`                                                                      |    no    |
| <a name="input_instance_size_override"></a> [instance\_size\_override](#input\_instance\_size\_override)                              | Provide different instance sizes for each individual aurora instance in the cluster. The size of the list must be equal to `var.amount_of_instances`. If ommitted or set to [], this module will use `var.size` for all the instances in the cluster.                            | `list(string)` | `[]`                                                                      |    no    |
| <a name="input_performance_insights_enabled"></a> [performance\_insights\_enabled](#input\_performance\_insights\_enabled)            | Specifies whether Performance Insights is enabled or not.                                                                                                                                                                                                                        | `bool`         | `false`                                                                   |    no    |
| <a name="input_project"></a> [project](#input\_project)                                                                               | The current project                                                                                                                                                                                                                                                              | `string`       | `""`                                                                      |    no    |
| <a name="input_rds_instance_name_overrides"></a> [rds\_instance\_name\_overrides](#input\_rds\_instance\_name\_overrides)             | List of names to override the default RDS instance names / identifiers.                                                                                                                                                                                                          | `list(string)` | `null`                                                                    |    no    |
| <a name="input_rds_username"></a> [rds\_username](#input\_rds\_username)                                                              | RDS root user                                                                                                                                                                                                                                                                    | `string`       | `"root"`                                                                  |    no    |
| <a name="input_size"></a> [size](#input\_size)                                                                                        | Instance size                                                                                                                                                                                                                                                                    | `string`       | `"db.t2.small"`                                                           |    no    |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot)                                       | Skip final snapshot when destroying RDS                                                                                                                                                                                                                                          | `bool`         | `false`                                                                   |    no    |
| <a name="input_snapshot_identifier"></a> [snapshot\_identifier](#input\_snapshot\_identifier)                                         | Specifies whether or not to create this cluster from a snapshot. You can use either the name or ARN when specifying a DB cluster snapshot, or the ARN when specifying a DB snapshot                                                                                              | `string`       | `null`                                                                    |    no    |
| <a name="input_storage_encrypted"></a> [storage\_encrypted](#input\_storage\_encrypted)                                               | Encrypt RDS storage                                                                                                                                                                                                                                                              | `bool`         | `true`                                                                    |    no    |
| <a name="input_tag"></a> [tag](#input\_tag)                                                                                           | A tag used to identify an RDS in a project that has more than one RDS                                                                                                                                                                                                            | `string`       | `""`                                                                      |    no    |

### Outputs

| Name                                                                                                                        | Description |
| --------------------------------------------------------------------------------------------------------------------------- | ----------- |
| <a name="output_aurora_cluster_id"></a> [aurora\_cluster\_id](#output\_aurora\_cluster\_id)                                 | n/a         |
| <a name="output_aurora_cluster_instances_id"></a> [aurora\_cluster\_instances\_id](#output\_aurora\_cluster\_instances\_id) | n/a         |
| <a name="output_aurora_port"></a> [aurora\_port](#output\_aurora\_port)                                                     | n/a         |
| <a name="output_aurora_sg_id"></a> [aurora\_sg\_id](#output\_aurora\_sg\_id)                                                | n/a         |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint)                                                                | n/a         |
| <a name="output_reader_endpoint"></a> [reader\_endpoint](#output\_reader\_endpoint)                                         | n/a         |

### Example

```tf
module "aurora" {
  source                          = "github.com/skyscrapers/terraform-rds//aurora"
  project                         = "myproject"
  environment                     = "production"
  size                            = "db.t2.small"
  password                        = "supersecurepassword"
  subnets                         = ["subnet-12345d67", "subnet-12345d68", "subnet-12345d69"]
  amount_of_instances             = 1
  security_groups                 = ["sg-12be345678905ebf1", "sg-1234567890aef"]
  enabled_cloudwatch_logs_exports = ["audit", "error", "slowquery"]
}
```

## rds-replica

Creates an RDS read replica instance, the replica `security_group` and a `subnet_group` if not passed as parameter

### Inputs

| Name                               | Description                                                                                                                                                                                                                                                                                                                               |     Type     |                           Default                           | Required |
| ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :----------: | :---------------------------------------------------------: | :------: |
| engine                             |                                                                                                                                                                                                                                                                                                                                           |    string    |                             n/a                             |   yes    |
| subnets                            | Subnets to deploy in                                                                                                                                                                                                                                                                                                                      | list(string) |                             n/a                             |   yes    |
| vpc\_id                            | ID of the VPC where to deploy in                                                                                                                                                                                                                                                                                                          |    string    |                             n/a                             |   yes    |
| allowed\_cidr\_blocks              | CIDR blocks that are allowed to access the RDS                                                                                                                                                                                                                                                                                            | list(string) |                            `[]`                             |    no    |
| auto\_minor\_version\_upgrade      | Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window.                                                                                                                                                                                                                      |    string    |                          `"true"`                           |    no    |
| backup\_retention\_period          | How long do you want to keep RDS Slave backups                                                                                                                                                                                                                                                                                            |    number    |                           `"14"`                            |    no    |
| custom\_parameter\_group\_name     | A custom parameter group name to attach to the RDS instance. If not provided it will use the default from the master instance                                                                                                                                                                                                             |    string    |                            `""`                             |    no    |
| enabled\_cloudwatch\_logs\_exports | List of log types to enable for exporting to CloudWatch logs. You can check the available log types per engine in the \[AWS RDS documentation\]\(https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER\_LogAccess.html#USER\_LogAccess.Procedural.UploadtoCloudWatch\).                                                             | list(string) |                            `[]`                             |    no    |
| environment                        | How do you want to call your environment, this is helpful if you have more than 1 VPC.                                                                                                                                                                                                                                                    |    string    |                       `"production"`                        |    no    |
| name                               | An optional custom name to give to the module's resources                                                                                                                                                                                                                                                                                 |    string    |                            `""`                             |    no    |
| number\_of\_replicas               | number of database repliacs default 1                                                                                                                                                                                                                                                                                                     |    string    |                            `"1"`                            |    no    |
| multi\_az                          | Multi AZ true or false                                                                                                                                                                                                                                                                                                                    |     bool     |                           `false`                           |    no    |
| ports                              |                                                                                                                                                                                                                                                                                                                                           |     map      | `{ "mysql": "3306", "oracle": "1521", "postgres": "5432" }` |    no    |
| project                            | The current project                                                                                                                                                                                                                                                                                                                       |    string    |                            `""`                             |    no    |
| replicate\_source\_db              | RDS source to replicate from                                                                                                                                                                                                                                                                                                              |    string    |                            `""`                             |    no    |
| publicly\_accessible               | Bool to control if instance is publicly accessible                                                                                                                                                                                                                                                                                        |   `false`    |                             no                              |
| security\_groups                   | Security groups that are allowed to access the RDS                                                                                                                                                                                                                                                                                        | list(string) |                            `[]`                             |    no    |
| size                               | Instance size                                                                                                                                                                                                                                                                                                                             |    string    |                       `"db.t2.small"`                       |    no    |
| storage\_encrypted                 | Encrypt RDS storage                                                                                                                                                                                                                                                                                                                       |    string    |                          `"true"`                           |    no    |
| tag                                | A tag used to identify an RDS in a project that has more than one RDS                                                                                                                                                                                                                                                                     |    string    |                            `""`                             |    no    |
| max\_allocated\_storage            | When configured, the upper limit to which Amazon RDS can automatically scale the storage of the DB instance. Configuring this will automatically ignore differences to allocated\_storage. Must be greater than or equal to allocated\_storage or 0 to disable Storage Autoscaling. If not set the default of the master instance is set. |    string    |                           `null`                            |    no    |
| allocated_storage                  | How many GBs of space does your database need? If not set the default of the master instance is set.                                                                                                                                                                                                                                      |    string    |                           `null`                            |    no    |

### Outputs

| Name         | Description |
| ------------ | ----------- |
| rds\_address |             |
| rds\_arn     |             |
| rds\_sg\_id  |             |

### Example

```tf
module "rds" {
  source              = "github.com/skyscrapers/terraform-rds//rds-replica"
  project             = "myproject"
  environment         = "production"
  size                = "db.t2.small"
  engine              = "postgres"
  security_groups     = ["sg-12be345678905ebf1", "sg-1234567890aef"]
  replicate_source_db = "arn:aws:rds:eu-west-1:123456789012:db:myproject-production-something-rds01"
  vpc_id              = "vpc-e123bc45"
  subnets             = ["subnet-12345d67", "subnet-12345d68", "subnet-12345d69"]
}
```

## snapshot-cross-account-replicator

This module creates snapshots of RDS instances based on a [configured frequency](#input\_snapshot\_schedule\_expression), and replicates them to a different region in a different AWS account.
To achieve this it creates several Lambda functions that take care of the copy operations in the different steps.

As an example, let's say we want to back up an RDS instance in AWS account `111111111111` in region `eu-west-1` to the AWS account `222222222222` in region `eu-central-1`. The whole replication process takes place in 4 steps:

1. A snapshot is created from the RDS instance, in the account `111111111111` in region `eu-west-1` . If the instance is KMS encrypted, the snapshot will be encrypted with the same key
2. The initial snapshot is copied to region `eu-central-1` within the source account `111111111111`. Snapshots cannot be copied to a different AWS account and region in the same copy operation, so it needs to happen in two steps. In this step, the snapshot is re-encrypted using a [KMS key](#input\_target\_account\_kms\_key\_id) in the target AWS account and region (`222222222222` & `eu-central-1`)
3. The resulting snapshot from step (2) is then copied over to its final destination, in account `222222222222` in region `eu-central-1`.

There are Lambda functions in place that will take care of cleaning up the initial and intermediate snapshots resulting from steps (1) and (2).

There's another Lambda function running in account `222222222222` in region `eu-central-1` that will periodically run and delete those snapshots that are older than the [configured retention period](#input\_retention\_period).

For monitoring, the module creates two SNS topics where CloudWatch will post alert messages in case there's problems running the Lambda functions. These SNS topics can be subscribed to upstream monitoring services like OpsGenie.

Take into account that for the copy operation and re-encryption process to work properly, the policy of the [provided KMS key](#input\_target\_account\_kms\_key\_id) in the target account needs to allow usage access to the root user of the source account. IAM policies to further grant access to the Lambda functions will be created within the module. [Check this AWS documentation page](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ShareSnapshot.html#USER_ShareSnapshot.Encrypted.KeyPolicy) to know more about how encrpyted snapshots can be shared between different accounts.

### Example

```terraform
data "aws_caller_identity" "source" {
  provider = aws.source
}

module "rds_replication" {
  source = "github.com/skyscrapers/terraform-rds//snapshot-cross-account-replicator?ref=6.1.0"

  name                      = "AuroraReplicator"
  is_aurora_cluster         = true
  rds_instance_ids          = var.rds_cluster_ids
  snapshot_schedule_period  = 12
  retention_period          = 4
  target_account_kms_key_id = aws_kms_key.rds_target.id

  providers = {
    aws.source       = aws.source
    aws.intermediate = aws.intermediate
    aws.target       = aws.target
  }
}

resource "aws_kms_key" "rds_target" {
  provider = aws.target

  description = "KMS key used to encrypt RDS"
  policy      = data.aws_iam_policy_document.rds_replication_key.json

  lifecycle {
    prevent_destroy = true
  }
}

data "aws_iam_policy_document" "rds_replication_key" {
  provider = aws.target

  statement {
    sid       = "Enable IAM policies in source & target accounts"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type             = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.source.account_id}:root",
        "arn:aws:iam::${var.target_aws_account}:root"
      ]
    }
  }
}
```

### Requirements

| Name                                                                      | Version |
| ------------------------------------------------------------------------- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0  |
| <a name="requirement_aws"></a> [aws](#requirement\_aws)                   | ~> 3.61 |

### Providers

| Name                                                                                     | Version |
| ---------------------------------------------------------------------------------------- | ------- |
| <a name="provider_archive"></a> [archive](#provider\_archive)                            | n/a     |
| <a name="provider_aws.intermediate"></a> [aws.intermediate](#provider\_aws.intermediate) | ~> 3.61 |
| <a name="provider_aws.source"></a> [aws.source](#provider\_aws.source)                   | ~> 3.61 |
| <a name="provider_aws.target"></a> [aws.target](#provider\_aws.target)                   | ~> 3.61 |

### Modules

| Name                                                                                                                                                         | Source                                                       | Version |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------ | ------- |
| <a name="module_cleanup_intermediate_lambda_monitoring"></a> [cleanup\_intermediate\_lambda\_monitoring](#module\_cleanup\_intermediate\_lambda\_monitoring) | github.com/skyscrapers/terraform-cloudwatch//lambda_function | 2.0.1   |
| <a name="module_cleanup_source_lambda_monitoring"></a> [cleanup\_source\_lambda\_monitoring](#module\_cleanup\_source\_lambda\_monitoring)                   | github.com/skyscrapers/terraform-cloudwatch//lambda_function | 2.0.1   |
| <a name="module_cleanup_target_lambda_monitoring"></a> [cleanup\_target\_lambda\_monitoring](#module\_cleanup\_target\_lambda\_monitoring)                   | github.com/skyscrapers/terraform-cloudwatch//lambda_function | 2.0.1   |
| <a name="module_step_1_lambda_monitoring"></a> [step\_1\_lambda\_monitoring](#module\_step\_1\_lambda\_monitoring)                                           | github.com/skyscrapers/terraform-cloudwatch//lambda_function | 2.0.1   |
| <a name="module_step_2_lambda_monitoring"></a> [step\_2\_lambda\_monitoring](#module\_step\_2\_lambda\_monitoring)                                           | github.com/skyscrapers/terraform-cloudwatch//lambda_function | 2.0.1   |
| <a name="module_step_3_lambda_monitoring"></a> [step\_3\_lambda\_monitoring](#module\_step\_3\_lambda\_monitoring)                                           | github.com/skyscrapers/terraform-cloudwatch//lambda_function | 2.0.1   |

### Resources

| Name                                                                                                                                                                  | Type        |
| --------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_cloudwatch_event_rule.invoke_cleanup_intermediate_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule)     | resource    |
| [aws_cloudwatch_event_rule.invoke_cleanup_source_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule)           | resource    |
| [aws_cloudwatch_event_rule.invoke_cleanup_target_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule)           | resource    |
| [aws_cloudwatch_event_rule.invoke_step_1_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule)                   | resource    |
| [aws_cloudwatch_event_rule.invoke_step_2_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule)                   | resource    |
| [aws_cloudwatch_event_rule.invoke_step_3_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule)                   | resource    |
| [aws_cloudwatch_event_target.invoke_cleanup_intermediate_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource    |
| [aws_cloudwatch_event_target.invoke_cleanup_source_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target)       | resource    |
| [aws_cloudwatch_event_target.invoke_cleanup_target_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target)       | resource    |
| [aws_cloudwatch_event_target.invoke_step_1_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target)               | resource    |
| [aws_cloudwatch_event_target.invoke_step_2_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target)               | resource    |
| [aws_cloudwatch_event_target.invoke_step_3_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target)               | resource    |
| [aws_iam_role.source_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                                    | resource    |
| [aws_iam_role.target_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                                    | resource    |
| [aws_iam_role_policy.source_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy)                                      | resource    |
| [aws_iam_role_policy.source_lambda_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy)                                  | resource    |
| [aws_iam_role_policy.target_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy)                                      | resource    |
| [aws_iam_role_policy.target_lambda_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy)                                  | resource    |
| [aws_iam_role_policy_attachment.source_lambda_exec_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)      | resource    |
| [aws_iam_role_policy_attachment.target_lambda_exec_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)      | resource    |
| [aws_lambda_function.cleanup_intermediate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function)                               | resource    |
| [aws_lambda_function.cleanup_source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function)                                     | resource    |
| [aws_lambda_function.cleanup_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function)                                     | resource    |
| [aws_lambda_function.step_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function)                                             | resource    |
| [aws_lambda_function.step_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function)                                             | resource    |
| [aws_lambda_function.step_3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function)                                             | resource    |
| [aws_lambda_permission.invoke_cleanup_intermediate_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission)             | resource    |
| [aws_lambda_permission.invoke_cleanup_source_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission)                   | resource    |
| [aws_lambda_permission.invoke_cleanup_target_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission)                   | resource    |
| [aws_lambda_permission.invoke_step_1_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission)                           | resource    |
| [aws_lambda_permission.invoke_step_2_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission)                           | resource    |
| [aws_lambda_permission.invoke_step_3_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission)                           | resource    |
| [aws_sns_topic.source_region_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic)                                            | resource    |
| [aws_sns_topic.target_region_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic)                                            | resource    |
| [aws_sns_topic_policy.source_region_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy)                              | resource    |
| [aws_sns_topic_policy.target_region_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy)                              | resource    |
| [archive_file.lambda_zip](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file)                                                    | data source |
| [aws_caller_identity.source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity)                                          | data source |
| [aws_caller_identity.target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity)                                          | data source |
| [aws_db_instance.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/db_instance)                                                     | data source |
| [aws_iam_policy_document.lambda_kms_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                  | data source |
| [aws_iam_policy_document.source_lambda_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)        | data source |
| [aws_iam_policy_document.source_lambda_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)               | data source |
| [aws_iam_policy_document.source_retion_sns_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                | data source |
| [aws_iam_policy_document.target_lambda_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)        | data source |
| [aws_iam_policy_document.target_lambda_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)               | data source |
| [aws_iam_policy_document.target_retion_sns_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                | data source |
| [aws_kms_key.target_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key)                                                      | data source |
| [aws_rds_cluster.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/rds_cluster)                                                     | data source |
| [aws_region.intermediate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region)                                                      | data source |
| [aws_region.source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region)                                                            | data source |
| [aws_region.target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region)                                                            | data source |

### Inputs

| Name                                                                                                                                  | Description                                                                                                                                                                                                                                                                          | Type           | Default                 | Required |
| ------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------- | ----------------------- | :------: |
| <a name="input_name"></a> [name](#input\_name)                                                                                        | Name of the setup                                                                                                                                                                                                                                                                    | `string`       | n/a                     |   yes    |
| <a name="input_rds_instance_ids"></a> [rds\_instance\_ids](#input\_rds\_instance\_ids)                                                | List of IDs of the RDS instances to back up. If using Aurora, provide the cluster IDs instead                                                                                                                                                                                        | `list(string)` | n/a                     |   yes    |
| <a name="input_target_account_kms_key_id"></a> [target\_account\_kms\_key\_id](#input\_target\_account\_kms\_key\_id)                 | KMS key to use to encrypt replicated RDS snapshots in the target AWS account                                                                                                                                                                                                         | `string`       | n/a                     |   yes    |
| <a name="input_is_aurora_cluster"></a> [is\_aurora\_cluster](#input\_is\_aurora\_cluster)                                             | Whether we're backing up Aurora clusters instead of RDS instances                                                                                                                                                                                                                    | `bool`         | `false`                 |    no    |
| <a name="input_lambda_monitoring_metric_period"></a> [lambda\_monitoring\_metric\_period](#input\_lambda\_monitoring\_metric\_period) | The metric period to use for the Lambdas CloudWatch alerts for monitoring. This should be equal or higher than the snapshoting period                                                                                                                                                | `number`       | `21600`                 |    no    |
| <a name="input_retention_period"></a> [retention\_period](#input\_retention\_period)                                                  | Snapshot retention period in days                                                                                                                                                                                                                                                    | `number`       | `14`                    |    no    |
| <a name="input_snapshot_schedule_expression"></a> [snapshot\_schedule\_expression](#input\_snapshot\_schedule\_expression)            | Snapshot frequency specified as a CloudWatch schedule expression. Can either be a `rate()` or `cron()` expression. Check the [AWS documentation](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html#CronExpressions) on how to compose such expression. | `string`       | `"cron(0 */6 * * ? *)"` |    no    |

### Outputs

| Name                                                                                                                          | Description                                        |
| ----------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------- |
| <a name="output_source_region_sns_topic_arn"></a> [source\_region\_sns\_topic\_arn](#output\_source\_region\_sns\_topic\_arn) | SNS topic ARN for the lambdas in the source region |
| <a name="output_target_region_sns_topic_arn"></a> [target\_region\_sns\_topic\_arn](#output\_target\_region\_sns\_topic\_arn) | SNS topic ARN for the lambdas in the target region |

## rds-proxy

Create an RDS proxy and configure IAM role to use for reading AWS Secrets to access the database.

### Inputs

| Name                         | Description                                                                                           | Type           | Default | Required |
| ---------------------------- | ----------------------------------------------------------------------------------------------------- | -------------- | ------- | :------: |
| db_instance_identifier       | ID of the database instance to set as the proxy target                                                | `any`          | n/a     |   yes    |
| db_secret_arns               | AWS Secret Manager ARNs to use to access the database credentials                                     | `list`         | n/a     |   yes    |
| engine                       | RDS engine: MYSQL or POSTGRES                                                                         | `any`          | n/a     |   yes    |
| environment                  | The current environment                                                                               | `any`          | n/a     |   yes    |
| project                      | The current project                                                                                   | `any`          | n/a     |   yes    |
| security_groups              | Security groups that are allowed to access the RDS                                                    | `list(string)` | n/a     |   yes    |
| subnets                      | Subnets to deploy in                                                                                  | `list(string)` | n/a     |   yes    |
| proxy_connection_timeout     | The number of seconds for a proxy to wait for a connection to become available in the connection pool | `number`       | `120`   |    no    |
| proxy_max_connection_percent | The maximum size of the connection pool for each target in a target group                             | `number`       | `100`   |    no    |

### Outputs

| Name           | Description                   |
| -------------- | ----------------------------- |
| proxy_endpoint | Endpoint of the created proxy |

### Example

```tf
module "rds_proxy" {
  source = "github.com/skyscrapers/terraform-rds//rds_proxy"
  subnets                    = data.terraform_remote_state.networking.outputs.private_db_subnets
  project                    = var.project
  environment                = terraform.workspace
  engine                     = "MYSQL"
  security_groups            = ["sg-aaaaa", "sg-bbbb"]
  db_instance_identifier     = module.rds_database.rds_id
  db_secret_arns             = [aws_secretsmanager_secret.db_user_rw.arn, aws_secretsmanager_secret.db_user_ro.arn]
}  
```
