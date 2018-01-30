# terraform-rds
Everything for RDS related terraform

## RDS
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
* [`default_parameter_group_family`]: String(optional) Parameter group family for the default parameter group, according to the chosen engine and engine version. Will be omitted if `rds_custom_parameter_group_name` is provided (default: `mysql5.7`)
* [`replicate_source_db`]: String(optional) RDS source to replicate from
* [`multi_az`]: bool(optional) Multi AZ for RDS master (default: true)
* [`backup_retention_period`]: int(optional) How long do you want to keep RDS backups (default: 14)
* [`apply_immediately`]: bool(optional) whether you want to Apply changes immediately (default: true)
* [`storage_encrypted`]: bool(optional) whether you want to Encrypt RDS storage (default: true)
* [`tag`]: String(optional) tag
* [`project`]: String(required) the name of the project this RDS belongs to
* [`environment`]: String(required) the name of the environment these subnets belong to (prod,stag,dev)
* [`number`]: int(optional) number of the database (default 01)
* [`skip_final_snapshot`]: bool(optional) Whether to skip creating a final snapshot when destroying the resource (default: false)
* [`rds_custom_parameter_group_name`]: String(optional) A custom parameter group name to attach to the RDS instance. If not provided a default one will be created
* [`availability_zone`]: string(optional) The availability zone where you want to launch your instance in
* [`snapshot_identifier`]: string(optional) Specifies whether or not to create this database from a snapshot. This correlates to the snapshot ID you'd find in the RDS console, e.g: rds:production-2015-06-26-06-05.

### Output:
 * [`rds_port`]: String: The port of the rds
 * [`rds_address`]: String: The hostname of the rds instance
 * [`rds_arn`]: String: The arn of the rds

### Example
```
module "rds" {
  source                   = "rds"
  vpc_id                   = "${module.vpc.vpc_id}"
  subnets                  = "${module.vpc.private_db_subnets}"
  project                  = "${var.project}"
  environment              = "${var.environment}"
  size                     = "${var.rds_size}"
  security_groups          = []
  rds_password             = "${var.rds_password}"
  multi_az                 = "${var.rds_multiaz}"
  backup_retention_period  = "${var.rds_retention_period}"
  rds_parameter_group_name = "mysql-rds-${var.project}-${var.environment}${var.tag}"
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

### Output:
 * [`aurora_port`]: String: The port of the rds
 * [`aurora_sg_id`]: String: The security group ID
 * [`endpoint`]: String: The DNS address of the RDS instance
 * [`reader_endpoint`]: String: A read-only endpoint for the Aurora cluster, automatically load-balanced across replicas

### Example
```
module "aurora" {
  source                   = "aurora"
  project                  = "${var.project}"
  environment              = "${var.environment}"
  password                 = "${var.rds_password}"
  subnets                  = "${module.vpc.private_db_subnets}"
  amount_of_instances      = 1
  rds_parameter_group_name = "${aws_db_parameter_group.rds_custom_parameter_group.name}"

  security_groups          = []
}
```

## RDS-REPLICA
Creates an RDS read replica instance,the replica security_group and a subnet_group if not passed as parameter

### Available variables:
* [`vpc_id`]: String(required): ID of the VPC where to deploy in
* [`security_groups`]: List(optional) Security groups that are allowed to access the RDS
* [`allowed_cidr_blocks`]: List(optional) CIDR blocks that are allowed to access the RDS
* [`subnets`]: List(required) Subnets to deploy the RDS in
* [`size`]: String(optional) RDS instance size
* [`engine`]: String(required) RDS type: `mysql`, `postgres` or `oracle`
* [`replicate_source_db`]: String(required) RDS source to replicate from. NOTE: this must be the ARN of the instance, otherwise you cannot specify the db_subnet_group_name
* [`name`]: String(optional) the name of the replica
* [`project`]: String(required) the name of the project this RDS belongs to
* [`environment`]: String(required) the name of the environment these subnets belong to (prod,stag,dev)
* [`number`]: int(optional) number of the replica (default 01)
* [`availability_zone`]: string(optional) The availability zone where you want to launch your instance in

### Output:
 * [`rds_address`]: String: The hostname of the rds instance
 * [`rds_arn`]: String: The arn of the rds
 * [`rds_sg_id`]: String: The security group created

### Example
```
module "rds" {
  source              = "rds-replica"
  engine              = "postgres"
  project             = "batch"
  size                = "db.t2.small"
  name                = "venues"
  security_groups     = ["${var.sg_bastion_id}"]
  replicate_source_db = "${var.rds_arn}"
  availability_zone   = "${var.availability_zone}"
  vpc_id              = "${var.vpc_id}"
  subnets             = "${var.subnets}"

}
```
