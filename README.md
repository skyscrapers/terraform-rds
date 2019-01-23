# terraform-rds

Terraform modules to manage RDS resources

## rds

Creates a RDS instance, security_group, subnet_group and parameter_group

### Available variables

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| allowed\_cidr\_blocks | CIDR blocks that are allowed to access the RDS | list | `<list>` | no |
| apply\_immediately | Apply changes immediately | string | `"true"` | no |
| auto\_minor\_version\_upgrade | Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window. | string | `"true"` | no |
| availability\_zone | The availability zone where you want to launch your instance in | string | `""` | no |
| backup\_retention\_period | How long do you want to keep RDS backups | string | `"14"` | no |
| default\_parameter\_group\_family | Parameter group family for the default parameter group, according to the chosen engine and engine version. Defaults to mysql5.7 | string | `"mysql5.7"` | no |
| engine | RDS engine: mysql, oracle, postgres. Defaults to mysql | string | `"mysql"` | no |
| engine\_version | Engine version to use, according to the chosen engine. You can check the available engine versions using the [AWS CLI](http://docs.aws.amazon.com/cli/latest/reference/rds/describe-db-engine-versions.html). Defaults to 5.7.17 for MySQL. | string | `"5.7.17"` | no |
| environment | How do you want to call your environment, this is helpful if you have more than 1 VPC. | string | `"production"` | no |
| maintenance\_window | The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi'. See RDS Maintenance Window docs for more information. | string | `"Mon:00:00-Mon:01:00"` | no |
| monitoring\_interval | The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. Valid Values: 0, 1, 5, 10, 15, 30, 60. | string | `"0"` | no |
| multi\_az | Multi AZ true or false | string | `"true"` | no |
| name | The name of the RDS instance | string | `""` | no |
| number | number of the database default 01 | string | `"01"` | no |
| project | The current project | string | `""` | no |
| rds\_custom\_parameter\_group\_name | A custom parameter group name to attach to the RDS instance. If not provided a default one will be used | string | `""` | no |
| rds\_password | RDS root password | string | n/a | yes |
| rds\_username | RDS root user | string | `"root"` | no |
| security\_groups | Security groups that are allowed to access the RDS | list | `<list>` | no |
| security\_groups\_count | Number of security groups provided in `security_groups` variable | string | `"0"` | no |
| size | Instance size | string | `"db.t2.small"` | no |
| skip\_final\_snapshot | Skip final snapshot when destroying RDS | string | `"false"` | no |
| snapshot\_identifier | Specifies whether or not to create this database from a snapshot. This correlates to the snapshot ID you'd find in the RDS console, e.g: rds:production-2015-06-26-06-05. | string | `""` | no |
| storage | How many GBs of space does your database need? | string | `"10"` | no |
| storage\_encrypted | Encrypt RDS storage | string | `"true"` | no |
| storage\_type | Type of storage you want to use | string | `"gp2"` | no |
| subnets | Subnets to deploy in | list | n/a | yes |
| tag | A tag used to identify an RDS in a project that has more than one RDS | string | `""` | no |
| vpc\_id | ID of the VPC where to deploy in | string | n/a | yes |

### Output

| Name | Description |
|------|-------------|
| aws_db_subnet_group_id | The subnet group id of the RDS instance |
| rds_address | The hostname of the RDS instance |
| rds_arn | The arn of the RDS instance |
| rds_id | The id of the RDS instance |
| rds_port | The port of the RDS instance |
| rds_sg_id | The security group id of the RDS instance |

### Example

```tf
module "rds" {
  source                = "github.com/skyscrapers/terraform-rds//rds"
  vpc_id                = "vpc-e123bc45"
  subnets               = ["subnet-12345d67", "subnet-12345d68", "subnet-12345d69"]
  project               = "myproject"
  environment           = "production"
  size                  = "db.t2.small"
  security_groups       = ["sg-12be345678905ebf1", "sg-1234567890aef"]
  security_groups_count = 2
  rds_password          = "supersecurepassword"
  multi_az              = "false"
}
```

## Aurora

Creates a Aurora cluster + instances, security_group, subnet_group and parameter_group

### Available variables

* [`security_groups`]: List(required) Security groups that are allowed to access the RDS
* [`subnets`]: List(required) Subnets to deploy the RDS in
* [`size`]: String(optional) RDS instance size
* [`password`]: String(required) RDS root password
* [`rds_username`]: String(optional) RDS root user (default: `root`)
* [`backup_retention_period`]: int(optional) How long do you want to keep RDS backups (default: 14)
* [`apply_immediately`]: bool(optional) whether you want to Apply changes immediately (default: true)
* [`storage_encrypted`]: bool(optional) whether you want to Encrypt RDS storage (default: true)
* [`tag`]: String(optional) tag
* [`project`]: String(required) the name of the project this RDS belongs to
* [`environment`]: String(required) the name of the environment these subnets belong to (prod,stag,dev)
* [`skip_final_snapshot`]: bool(optional) Whether to skip creating a final snapshot when destroying the resource (default: false)
* [`cluster_parameter_group_name`]: String(optional) the parameter group that is used for the cluster (default: The default aurora cluster group)
* [`instance_parameter_group_name`]: String(optional) the parameter group that is used for the instances of the cluster (default: aurora-rds-${var.project}-${var.environment}${var.tag})
* [`amount_of_instances`]: Integer(optional) How many aurora instances do you need, minimum 2 are needed for HA (default: 1)
* [`engine`]: String(optional) Aurora engine: `aurora`, `aurora-postgresql` or `aurora-mysql` (default: `aurora`)
* [`engine_version`]: String(optional) Engine version to use, according to the chosen engine. You can check the available engine versions using the AWS CLI (http://docs.aws.amazon.com/cli/latest/reference/rds/describe-db-engine-versions.html) (default: `5.6.10a` - for MySQL)
* [`family`]: String(optional) Parameter group family for the default parameter group, according to the chosen engine and engine version. (default: `aurora5.6` - for MySQL)
* [`default_ports`]: Map(optional) The default ports for aurora and aurora-postgresql. (default: `3306` and `5432`)

### Output

 * [`aurora_port`]: String: The port of the rds
 * [`aurora_sg_id`]: String: The security group ID
 * [`endpoint`]: String: The DNS address of the RDS instance
 * [`reader_endpoint`]: String: A read-only endpoint for the Aurora cluster, automatically load-balanced across replicas

### Example

```tf
module "aurora" {
  source              = "github.com/skyscrapers/terraform-rds//aurora"
  project             = "myproject"
  environment         = "production"
  size                = "db.t2.small"
  password            = "supersecurepassword"
  subnets             = ["subnet-12345d67", "subnet-12345d68", "subnet-12345d69"]
  amount_of_instances = 1
  security_groups     = ["sg-12be345678905ebf1", "sg-1234567890aef"]
}
```

## rds-replica

Creates an RDS read replica instance, the replica `security_group` and a `subnet_group` if not passed as parameter

### Available variables

* [`vpc_id`]: String(required): ID of the VPC where to deploy in
* [`security_groups`]: List(optional) Security groups that are allowed to access the RDS
* [`allowed_cidr_blocks`]: List(optional) CIDR blocks that are allowed to access the RDS
* [`subnets`]: List(required) Subnets to deploy the RDS in
* [`size`]: String(optional) RDS instance size
* [`engine`]: String(required) RDS type: `mysql`, `postgres` or `oracle`
* [`replicate_source_db`]: String(required) RDS source to replicate from. NOTE: this must be the ARN of the instance, otherwise you cannot specify the db_subnet_group_name
* [`tag`]: String(optional) the tag of the replica
* [`project`]: String(required) the name of the project this RDS belongs to
* [`environment`]: String(required) the name of the environment these subnets belong to (prod,stag,dev)
* [`number_of_replicas`]: int(optional) number of read replicas (default 1)
* [`name`]: string(optional) name of the resources (default to <project>-<environment><tag>-rds<number>-replica)
* [`storage_encrypted`]: bool(optional) whether you want to Encrypt RDS storage (default: true)
* [`custom_parameter_group_name`]: String(optional) A custom parameter group name to attach to the RDS instance. If not provided it will use the default from the master instance

### Output

 * [`rds_address`]: String: The hostname of the rds instance
 * [`rds_arn`]: String: The arn of the rds
 * [`rds_sg_id`]: String: The security group created

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
