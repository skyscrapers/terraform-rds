# Create RDS with Subnet and paramter group,
resource "aws_security_group" "sg_rds" {
  name        = "sg_rds_${var.project}_${var.environment}${var.tag}"
  description = "Security group that is needed for the RDS"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name        = "${var.project}-${var.environment}${var.tag}-sg_rds"
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }
}

resource "aws_security_group_rule" "rds_sg_in" {
  count                    = "${length(var.security_groups)}"
  security_group_id        = "${aws_security_group.sg_rds.id}"
  type                     = "ingress"
  from_port                = "${lookup(var.ports, var.rds_type)}"
  to_port                  = "${lookup(var.ports, var.rds_type)}"
  protocol                 = "tcp"
  source_security_group_id = "${element(var.security_groups, count.index)}"
}

resource "aws_security_group_rule" "rds_cidr_in" {
  security_group_id = "${aws_security_group.sg_rds.id}"
  type              = "ingress"
  from_port         = "${lookup(var.ports, var.rds_type)}"
  to_port           = "${lookup(var.ports, var.rds_type)}"
  protocol          = "tcp"
  cidr_blocks       = ["${var.allowed_cidr_blocks}"]
}
