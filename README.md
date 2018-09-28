# terraform-rds

Terraform modules to manage RDS resources

## rds
Creates a RDS instance, security_group, subnet_group and parameter_group

### Available variables:
* [`vpc_id`]: String(required): ID of the VPC where to deploy in
* [`security_groups`]: List(optional) Security groups that are allowed to access the RDS
* [`allowed_cidr_blocks`]: List(optional) CIDR blocks that are allowed to access the RDS
* [`subnets`]: List(required) Subnets to deploy the RDS in
* [`storage`]: String(optional) How many GBs of space does your database need?
* [`size`]: String(optional) RDS instance size
* [`storage_type`]: String(optional) Type of storage you want to use (default: `gp2`)
* [`rds_password`]: String(required) RDS root password
* [`rds_username`]: String(optional) RDS root user (default: `root`)
* [`engine`]: String(optional) RDS engine: `mysql`, `postgres` or `oracle` (default: `mysql`)
* [`engine_version`]: String(optional) Engine version to use, according to the chosen engine. You can check the available engine versions using the AWS CLI (http://docs.aws.amazon.com/cli/latest/reference/rds/describe-db-engine-versions.html) (default: `5.7.17` - for MySQL)
* [`default_parameter_group_family`]: String(optional) Parameter group family for the default parameter group, according to the chosen engine and engine version. Defaults to `mysql5.7`
* [`multi_az`]: bool(optional) Multi AZ for RDS master (default: true)
* [`backup_retention_period`]: int(optional) How long do you want to keep RDS backups (default: 14)
* [`apply_immediately`]: bool(optional) whether you want to Apply changes immediately (default: true)
* [`storage_encrypted`]: bool(optional) whether you want to Encrypt RDS storage (default: true)
* [`tag`]: String(optional) tag
* [`project`]: String(required) the name of the project this RDS belongs to
* [`environment`]: String(required) the name of the environment these subnets belong to (prod,stag,dev)
* [`number`]: int(optional) number of the database (default 01)
* [`skip_final_snapshot`]: bool(optional) Whether to skip creating a final snapshot when destroying the resource (default: false)
* [`rds_custom_parameter_group_name`]: String(optional) A custom parameter group name to attach to the RDS instance. If not provided a default one will be used
* [`availability_zone`]: string(optional) The availability zone where you want to launch your instance in
* [`snapshot_identifier`]: string(optional) Specifies whether or not to create this database from a snapshot. This correlates to the snapshot ID you'd find in the RDS console, e.g: rds:production-2015-06-26-06-05.
* [`name`]: String(optional) Name of the resources (default to <project>-<environment><tag>-rds<number>)

### Output:
 * [`rds_port`]: String: The port of the rds
 * [`rds_address`]: String: The hostname of the rds instance
 * [`rds_arn`]: String: The arn of the rds

### Example
```
module "rds" {
  source          = "github.com/skyscrapers/terraform-rds//rds"
  vpc_id          = "vpc-e123bc45"
  subnets         = ["subnet-12345d67", "subnet-12345d68", "subnet-12345d69"]
  project         = "myproject"
  environment     = "production"
  size            = "db.t2.small"
  security_groups = ["sg-12be345678905ebf1", "sg-1234567890aef"]
  rds_password    = "supersecurepassword"
  multi_az        = "false"
}
```

## Aurora
Creates a Aurora cluster + instances, security_group, subnet_group and parameter_group

### Available variables:
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

### Output:
 * [`aurora_port`]: String: The port of the rds
 * [`aurora_sg_id`]: String: The security group ID
 * [`endpoint`]: String: The DNS address of the RDS instance
 * [`reader_endpoint`]: String: A read-only endpoint for the Aurora cluster, automatically load-balanced across replicas

### Example
```
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

### Available variables:
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
* [`number`]: int(optional) number of the replica (default 01)
* [`name`]: string(optional) name of the resources (default to <project>-<environment><tag>-rds<number>-replica)
* [`storage_encrypted`]: bool(optional) whether you want to Encrypt RDS storage (default: true)

### Output:
 * [`rds_address`]: String: The hostname of the rds instance
 * [`rds_arn`]: String: The arn of the rds
 * [`rds_sg_id`]: String: The security group created

### Example
```
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
