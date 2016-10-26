# Create RDS with Subnet and paramter group,
resource "aws_security_group" "sg_rds" {
  name = "sg_rds_${var.project}_${var.environment}${var.tag}"
  description = "Security group that is needed for the RDS"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port = "${lookup(var.ports, var.rds_type)}"
    to_port = "${lookup(var.ports, var.rds_type)}"
    protocol = "tcp"
    security_groups  = ["${split(",", var.security_groups)}"]
  }

  tags {
    Name = "${var.project}-${var.environment}${var.tag}-sg_rds"
    Environment = "${var.environment}"
    Project = "${var.project}"
  }
}
