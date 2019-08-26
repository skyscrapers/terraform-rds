data "aws_subnet" "subnet" {
  id = "${var.subnets[0]}"
}

locals {
  port = "${var.default_ports[var.engine]}"
}

# Create RDS with Subnet and paramter group,
resource "aws_security_group" "sg_aurora" {
  name        = "sg_aurora_${var.project}_${var.environment}${var.tag}"
  description = "Security group that is needed for the Aurora"
  vpc_id      = data.aws_subnet.subnet.vpc_id

  tags = {
    Name        = "${var.project}-${var.environment}${var.tag}-sg_aurora"
    Environment = var.environment
    Project     = var.project
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}

resource "aws_security_group_rule" "sg_aurora_in" {
  count                    = length(var.security_groups)
  security_group_id        = aws_security_group.sg_aurora.id
  type                     = "ingress"
  from_port                = local.port
  to_port                  = local.port
  protocol                 = "tcp"
  source_security_group_id = element(var.security_groups, count.index)
}
