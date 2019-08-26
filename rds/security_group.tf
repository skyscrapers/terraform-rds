# Create RDS with Subnet and paramter group,
resource "aws_security_group" "sg_rds" {
  name        = length(var.name) == 0 ? "${var.project}-${var.environment}${var.tag}" : "${var.name}-rds"
  description = "Security group that is needed for the RDS"
  vpc_id      = var.vpc_id

  tags = {
    Name        = length(var.name) == 0 ? "${var.project}-${var.environment}${var.tag}" : "${var.name}-rds"
    Environment = var.environment
    Project     = var.project
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}

resource "aws_security_group_rule" "rds_sg_in" {
  count                    = var.security_groups_count
  security_group_id        = aws_security_group.sg_rds.id
  type                     = "ingress"
  from_port                = local.port
  to_port                  = local.port
  protocol                 = "tcp"
  source_security_group_id = element(var.security_groups, count.index)
}

resource "aws_security_group_rule" "rds_cidr_in" {
  count             = length(var.allowed_cidr_blocks) == 0 ? 0 : 1
  security_group_id = aws_security_group.sg_rds.id
  type              = "ingress"
  from_port         = local.port
  to_port           = local.port
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
}
