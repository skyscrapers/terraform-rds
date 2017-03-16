data "aws_subnet" "subnet" {
  id = "${var.subnets[0]}"
}

# Create RDS with Subnet and paramter group,
resource "aws_security_group" "sg_aurora" {
  name        = "sg_aurora_${var.project}_${var.environment}${var.tag}"
  description = "Security group that is needed for the Aurora"
  vpc_id      = "${data.aws_subnet.subnet.vpc_id}"

  ingress {
    from_port       = "3306"
    to_port         = "3306"
    protocol        = "tcp"
    security_groups = ["${var.security_groups}"]
  }

  tags {
    Name        = "${var.project}-${var.environment}${var.tag}-sg_aurora"
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }
}
