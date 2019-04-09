resource "aws_security_group" "habitat_branch_lab" {
  name        = "habitat_branch_lab_${random_id.instance_id.hex}"
  description = "base rules for habitat_branch_lab demo"
  vpc_id      = "${aws_vpc.habitat_branch_lab_vpc.id}"

  tags {
    Name          = "${var.tag_customer}-${var.tag_project}_${random_id.instance_id.hex}_${var.tag_application}_security_group"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}

resource "aws_security_group" "habitat_supervisor" {
  name        = "habitat_supervisor_${random_id.instance_id.hex}"
  description = "SG rules to allow Habitat supervisor to communicate privately"
  vpc_id      = "${aws_vpc.habitat_branch_lab_vpc.id}"

  tags {
    Name          = "${var.tag_customer}-${var.tag_project}_${random_id.instance_id.hex}_${var.tag_application}_security_group"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Application = "${var.tag_application}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }
}

//////////////////////////
// habitat_branch_lab Parks SG Rules 
resource "aws_security_group_rule" "ingress_allow_22_tcp_all" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.habitat_branch_lab.id}"
}

resource "aws_security_group_rule" "ingress_allow_443_tcp_all" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.habitat_branch_lab.id}"
}

resource "aws_security_group_rule" "ingress_rdp_all" {
  type              = "ingress"
  from_port         = 3389
  to_port           = 3389
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.habitat_branch_lab.id}"
}

resource "aws_security_group_rule" "ingress_winrm_all" {
  type              = "ingress"
  from_port         = 5985
  to_port           = 5985
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.habitat_branch_lab.id}"
}

resource "aws_security_group_rule" "ingress_allow_9631_tcp_all" {
  type              = "ingress"
  from_port         = 9631
  to_port           = 9631
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.habitat_branch_lab.id}"
}

resource "aws_security_group_rule" "ingress_allow_9632_tcp_all" {
  type              = "ingress"
  from_port         = 9632
  to_port           = 9632
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.habitat_branch_lab.id}"
}

/////////////////////////
// Habitat Supervisor Rules
# Allow Habitat Supervisor http communication tcp
resource "aws_security_group_rule" "ingress_allow_9631_tcp" {
  type                     = "ingress"
  from_port                = 9631
  to_port                  = 9631
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.habitat_supervisor.id}"
  source_security_group_id = "${aws_security_group.habitat_supervisor.id}"
}

# Allow Habitat Supervisor http communication udp
resource "aws_security_group_rule" "ingress_allow_9631_udp" {
  type                     = "ingress"
  from_port                = 9631
  to_port                  = 9631
  protocol                 = "udp"
  security_group_id        = "${aws_security_group.habitat_supervisor.id}"
  source_security_group_id = "${aws_security_group.habitat_supervisor.id}"
}

# Allow Habitat Supervisor ZeroMQ communication tcp
resource "aws_security_group_rule" "ingress_9638_tcp" {
  type                     = "ingress"
  from_port                = 9638
  to_port                  = 9638
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.habitat_supervisor.id}"
  source_security_group_id = "${aws_security_group.habitat_supervisor.id}"
}

# Allow Habitat Supervisor ZeroMQ communication udp
resource "aws_security_group_rule" "ingress_allow_9638_udp" {
  type                     = "ingress"
  from_port                = 9638
  to_port                  = 9638
  protocol                 = "udp"
  security_group_id        = "${aws_security_group.habitat_supervisor.id}"
  source_security_group_id = "${aws_security_group.habitat_supervisor.id}"
}

# Egress: ALL
resource "aws_security_group_rule" "linux_egress_allow_0-65535_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.habitat_branch_lab.id}"
}

# MongoDB
resource "aws_security_group_rule" "ingress_allow_27017_tcp" {
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27018
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.habitat_supervisor.id}"
  source_security_group_id = "${aws_security_group.habitat_supervisor.id}"
}

resource "aws_security_group_rule" "ingress_allow_8080_8085_tcp" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8085
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.habitat_supervisor.id}"
  source_security_group_id = "${aws_security_group.habitat_supervisor.id}"
}
