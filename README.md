# terraform-rds

Terraform modules to manage RDS resources

## rds

Creates a RDS instance, security_group, subnet_group and parameter_group

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| rds\_password | RDS root password | string | n/a | yes |
| security\_groups | Security groups that are allowed to access the RDS | list(string) | n/a | yes |
| security\_groups\_count | Number of security groups provided in `security\_groups` variable | string | n/a | yes |
| subnets | Subnets to deploy in | list(string) | n/a | yes |
| vpc\_id | ID of the VPC where to deploy in | string | n/a | yes |
| allowed\_cidr\_blocks | CIDR blocks that are allowed to access the RDS | list(string) | `[]` | no |
| apply\_immediately | Apply changes immediately | string | `"true"` | no |
| auto\_minor\_version\_upgrade | Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window. | string | `"true"` | no |
| availability\_zone | The availability zone where you want to launch your instance in | string | `""` | no |
| backup\_retention\_period | How long do you want to keep RDS backups | string | `"14"` | no |
| default\_parameter\_group\_family | Parameter group family for the default parameter group, according to the chosen engine and engine version. Defaults to mysql5.7 | string | `"mysql5.7"` | no |
| enabled\_cloudwatch\_logs\_exports | List of log types to enable for exporting to CloudWatch logs. You can check the available log types per engine in the \[AWS RDS documentation\]\(https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER\_LogAccess.html#USER\_LogAccess.Procedural.UploadtoCloudWatch\). | list(string) | `[]` | no |
| engine | RDS engine: mysql, oracle, postgres. Defaults to mysql | string | `"mysql"` | no |
| engine\_version | Engine version to use, according to the chosen engine. You can check the available engine versions using the \[AWS CLI\]\(http://docs.aws.amazon.com/cli/latest/reference/rds/describe-db-engine-versions.html\). Defaults to 5.7.17 for MySQL. | string | `"5.7.25"` | no |
| environment | How do you want to call your environment, this is helpful if you have more than 1 VPC. | string | `"production"` | no |
| maintenance\_window | The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi'. See RDS Maintenance Window docs for more information. | string | `"Mon:00:00-Mon:01:00"` | no |
| max\_allocated\_storage | When configured, the upper limit to which Amazon RDS can automatically scale the storage of the DB instance. Configuring this will automatically ignore differences to allocated\_storage. Must be greater than or equal to allocated\_storage or 0 to disable Storage Autoscaling. | string | `"0"` | no |
| monitoring\_interval | The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. Valid Values: 0, 1, 5, 10, 15, 30, 60. | string | `"0"` | no |
| multi\_az | Multi AZ true or false | string | `"true"` | no |
| name | The name of the RDS instance | string | `""` | no |
| number | number of the database default 01 | string | `"01"` | no |
| performance\_insights\_enabled | Specifies whether Performance Insights is enabled or not. | bool | `"false"` | no |
| project | The current project | string | `""` | no |
| rds\_custom\_parameter\_group\_name | A custom parameter group name to attach to the RDS instance. If not provided a default one will be used | string | `""` | no |
| rds\_username | RDS root user | string | `"root"` | no |
| size | Instance size | string | `"db.t2.small"` | no |
| skip\_final\_snapshot | Skip final snapshot when destroying RDS | string | `"false"` | no |
| snapshot\_identifier | Specifies whether or not to create this database from a snapshot. This correlates to the snapshot ID you'd find in the RDS console, e.g: rds:production-2015-06-26-06-05. | string | `""` | no |
| storage | How many GBs of space does your database need? | string | `"10"` | no |
| storage\_encrypted | Encrypt RDS storage | string | `"true"` | no |
| storage\_type | Type of storage you want to use | string | `"gp2"` | no |
| tag | A tag used to identify an RDS in a project that has more than one RDS | string | `""` | no |

### Outputs

| Name | Description |
|------|-------------|
| aws\_db\_subnet\_group\_id | The subnet group id of the RDS instance |
| rds\_address | The hostname of the RDS instance |
| rds\_arn | The arn of the RDS instance |
| rds\_id | The id of the RDS instance |
| rds\_port | The port of the RDS instance |
| rds\_sg\_id | The security group id of the RDS instance |

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

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| password | RDS root password | `any` | n/a | yes |
| security_groups | Security groups that are allowed to access the RDS on port 3306 | `list(string)` | n/a | yes |
| subnets | Subnets to deploy in | `list(string)` | n/a | yes |
| amount_of_instances | The amount of Aurora instances you need, for HA you need minumum 2 | `number` | `1` | no |
| apply_immediately | Apply changes immediately | `bool` | `true` | no |
| backup_retention_period | How long do you want to keep RDS backups | `string` | `"14"` | no |
| cluster_parameter_group_name | Optional parameter group you can set for the RDS Aurora cluster | `string` | `""` | no |
| default_ports | n/a | `map` | <pre>{<br>  "aurora": "3306",<br>  "aurora-postgresql": "5432"<br>}</pre> | no |
| enabled_cloudwatch_logs_exports | List of log types to enable for exporting to CloudWatch logs. You can check the available log types per engine in the [AWS Aurora documentation](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/USER_LogAccess.html#USER_LogAccess.Procedural.UploadtoCloudWatch). | `list(string)` | `[]` | no |
| engine | Optional parameter to set the Aurora engine | `string` | `"aurora"` | no |
| engine_version | Optional parameter to set the Aurora engine version | `string` | `"5.6.10a"` | no |
| environment | How do you want to call your environment, this is helpful if you have more than 1 VPC. | `string` | `"production"` | no |
| family | n/a | `string` | `"aurora5.6"` | no |
| instance_parameter_group_name | Optional parameter group you can set for the RDS instances inside an Aurora cluster | `string` | `""` | no |
| performance_insights_enabled | Specifies whether Performance Insights is enabled or not. | `bool` | `false` | no |
| project | The current project | `string` | `""` | no |
| rds_instance_name_overrides | List of names to override the default RDS instance names / identifiers. | `list(string)` | `null` | no |
| rds_username | RDS root user | `string` | `"root"` | no |
| size | Instance size | `string` | `"db.t2.small"` | no |
| skip_final_snapshot | Skip final snapshot when destroying RDS | `bool` | `false` | no |
| snapshot_identifier | Specifies whether or not to create this cluster from a snapshot. You can use either the name or ARN when specifying a DB cluster snapshot, or the ARN when specifying a DB snapshot | `string` | `null` | no |
| storage_encrypted | Encrypt RDS storage | `bool` | `true` | no |
| tag | A tag used to identify an RDS in a project that has more than one RDS | `string` | `""` | no |

### Outputs

| Name | Description |
|------|-------------|
| aurora_cluster_id | n/a |
| aurora_cluster_instances_id | n/a |
| aurora_port | n/a |
| aurora_sg_id | n/a |
| endpoint | n/a |
| reader_endpoint | n/a |

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

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| engine |  | string | n/a | yes |
| subnets | Subnets to deploy in | list(string) | n/a | yes |
| vpc\_id | ID of the VPC where to deploy in | string | n/a | yes |
| allowed\_cidr\_blocks | CIDR blocks that are allowed to access the RDS | list(string) | `[]` | no |
| auto\_minor\_version\_upgrade | Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window. | string | `"true"` | no |
| backup\_retention\_period | How long do you want to keep RDS Slave backups | number | `"14"` | no |
| custom\_parameter\_group\_name | A custom parameter group name to attach to the RDS instance. If not provided it will use the default from the master instance | string | `""` | no |
| enabled\_cloudwatch\_logs\_exports | List of log types to enable for exporting to CloudWatch logs. You can check the available log types per engine in the \[AWS RDS documentation\]\(https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER\_LogAccess.html#USER\_LogAccess.Procedural.UploadtoCloudWatch\). | list(string) | `[]` | no |
| environment | How do you want to call your environment, this is helpful if you have more than 1 VPC. | string | `"production"` | no |
| name | An optional custom name to give to the module's resources | string | `""` | no |
| number\_of\_replicas | number of database repliacs default 1 | string | `"1"` | no |
| multi\_az | Multi AZ true or false | bool | `false` | no |
| ports |  | map | `{ "mysql": "3306", "oracle": "1521", "postgres": "5432" }` | no |
| project | The current project | string | `""` | no |
| replicate\_source\_db | RDS source to replicate from | string | `""` | no |
| publicly\_accessible | Bool to control if instance is publicly accessible | `false` | no |
| security\_groups | Security groups that are allowed to access the RDS | list(string) | `[]` | no |
| size | Instance size | string | `"db.t2.small"` | no |
| storage\_encrypted | Encrypt RDS storage | string | `"true"` | no |
| tag | A tag used to identify an RDS in a project that has more than one RDS | string | `""` | no |
| max\_allocated\_storage | When configured, the upper limit to which Amazon RDS can automatically scale the storage of the DB instance. Configuring this will automatically ignore differences to allocated\_storage. Must be greater than or equal to allocated\_storage or 0 to disable Storage Autoscaling. If not set the default of the master instance is set. | string | `null` | no |
| allocated_storage | How many GBs of space does your database need? If not set the default of the master instance is set. | string | `null` | no |

### Outputs

| Name | Description |
|------|-------------|
| rds\_address |  |
| rds\_arn |  |
| rds\_sg\_id |  |

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

### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_aws.intermediate"></a> [aws.intermediate](#provider\_aws.intermediate) | n/a |
| <a name="provider_aws.source"></a> [aws.source](#provider\_aws.source) | n/a |
| <a name="provider_aws.target"></a> [aws.target](#provider\_aws.target) | n/a |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cleanup_snapshots_lambda_monitoring"></a> [cleanup\_snapshots\_lambda\_monitoring](#module\_cleanup\_snapshots\_lambda\_monitoring) | github.com/skyscrapers/terraform-cloudwatch//lambda_function | 2.0.0 |
| <a name="module_step_1_lambda_monitoring"></a> [step\_1\_lambda\_monitoring](#module\_step\_1\_lambda\_monitoring) | github.com/skyscrapers/terraform-cloudwatch//lambda_function | 2.0.0 |
| <a name="module_step_2_lambda_monitoring"></a> [step\_2\_lambda\_monitoring](#module\_step\_2\_lambda\_monitoring) | github.com/skyscrapers/terraform-cloudwatch//lambda_function | 2.0.0 |
| <a name="module_step_3_lambda_monitoring"></a> [step\_3\_lambda\_monitoring](#module\_step\_3\_lambda\_monitoring) | github.com/skyscrapers/terraform-cloudwatch//lambda_function | 2.0.0 |
| <a name="module_step_4_lambda_monitoring"></a> [step\_4\_lambda\_monitoring](#module\_step\_4\_lambda\_monitoring) | github.com/skyscrapers/terraform-cloudwatch//lambda_function | 2.0.0 |

### Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.invoke_cleanup_snapshots_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.invoke_step_1_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.invoke_step_2_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.invoke_step_3_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.invoke_step_4_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.invoke_cleanup_snapshots_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.invoke_step_1_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.invoke_step_2_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.invoke_step_3_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.invoke_step_4_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_role.source_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.step_4_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.target_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.cleanup_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.source_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.source_lambda_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.target_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.target_lambda_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.source_lambda_exec_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.target_lambda_exec_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.cleanup_snapshots](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function.step_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function.step_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function.step_3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function.step_4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.invoke_cleanup_snapshots_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.invoke_step_1_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.invoke_step_2_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.invoke_step_3_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.invoke_step_4_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_sns_topic.source_region_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic.target_region_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [archive_file.lambda_zip](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_caller_identity.target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_db_instance.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/db_instance) | data source |
| [aws_iam_policy_document.lambda_kms_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.source_lambda_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.source_lambda_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.step_4_lambda_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.step_4_lambda_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.target_lambda_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.target_lambda_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_kms_key.target_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key) | data source |
| [aws_region.intermediate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_region.source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_region.target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name of the setup | `string` | n/a | yes |
| <a name="input_rds_instance_ids"></a> [rds\_instance\_ids](#input\_rds\_instance\_ids) | List of IDs of the RDS instances to back up | `list(string)` | n/a | yes |
| <a name="input_target_account_kms_key_id"></a> [target\_account\_kms\_key\_id](#input\_target\_account\_kms\_key\_id) | KMS key to use to encrypt replicated RDS snapshots in the target AWS account | `string` | n/a | yes |
| <a name="input_retention_period"></a> [retention\_period](#input\_retention\_period) | Snapshot retention period in days | `number` | `25` | no |
| <a name="input_snapshot_schedule_expression"></a> [snapshot\_schedule\_expression](#input\_snapshot\_schedule\_expression) | Snapshot frequency specified as a CloudWatch schedule expression. Can either be a `rate()` or `cron()` expression. Check the [AWS documentation](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html#CronExpressions) on how to compose such expression. | `string` | `"cron(0 */6 * * ? *)"` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_source_region_sns_topic_arn"></a> [source\_region\_sns\_topic\_arn](#output\_source\_region\_sns\_topic\_arn) | SNS topic ARN for the lambdas in the source region |
| <a name="output_target_region_sns_topic_arn"></a> [target\_region\_sns\_topic\_arn](#output\_target\_region\_sns\_topic\_arn) | SNS topic ARN for the lambdas in the target region |

## rds-proxy

Create an RDS proxy and configure IAM role to use for reading AWS Secrets to access the database.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| db_instance_identifier | ID of the database instance to set as the proxy target | `any` | n/a | yes |
| db_secret_arns | AWS Secret Manager ARNs to use to access the database credentials | `list` | n/a | yes |
| engine | RDS engine: MYSQL or POSTGRES | `any` | n/a | yes |
| environment | The current environment | `any` | n/a | yes |
| project | The current project | `any` | n/a | yes |
| security_groups | Security groups that are allowed to access the RDS | `list(string)` | n/a | yes |
| subnets | Subnets to deploy in | `list(string)` | n/a | yes |
| proxy_connection_timeout | The number of seconds for a proxy to wait for a connection to become available in the connection pool | `number` | `120` | no |
| proxy_max_connection_percent | The maximum size of the connection pool for each target in a target group | `number` | `100` | no |

### Outputs

| Name | Description |
|------|-------------|
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
