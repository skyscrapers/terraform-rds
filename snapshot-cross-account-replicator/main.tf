terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      configuration_aliases = [
        aws.source,
        aws.target
      ]
    }
  }
}

data "aws_caller_identity" "source" {
  provider = aws.source
}

data "aws_region" "source" {
  provider = aws.source
}

data "aws_caller_identity" "target" {
  provider = aws.target
}

data "aws_region" "target" {
  provider = aws.target
}

data "aws_db_instance" "rds" {
  provider               = aws.source
  for_each               = toset(var.rds_instance_ids)
  db_instance_identifier = each.key
}

locals {
  setup_name = "rds-snapshot-cross-account-replicator-${var.name}"
}