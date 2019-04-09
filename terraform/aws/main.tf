provider "aws" {
  region                  = "${var.aws_region}"
  profile                 = "${var.aws_profile}"
  shared_credentials_file = "~/.aws/credentials"
}

resource "random_id" "instance_id" {
  byte_length = 4
}

data "aws_availability_zones" "available" {}


////////////////////////////////
// VPC 

resource "aws_vpc" "habitat_branch_lab_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name          = "${var.tag_name}-vpc"
    X-Dept        = "${var.tag_dept}"
    X-Customer    = "${var.tag_customer}"
    X-Project     = "${var.tag_project}"
    X-Contact     = "${var.tag_contact}"
    X-Application = "${var.tag_application}"
    X-TTL         = "${var.tag_ttl}"
  }
}

resource "aws_internet_gateway" "habitat_branch_lab_gateway" {
  vpc_id = "${aws_vpc.habitat_branch_lab_vpc.id}"

  tags {
    Name = "${var.tag_name}_habitat_branch_lab_gateway-${var.tag_application}"
  }
}

resource "aws_route" "habitat_branch_lab_internet_access" {
  route_table_id         = "${aws_vpc.habitat_branch_lab_vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.habitat_branch_lab_gateway.id}"
}

resource "aws_subnet" "habitat_branch_lab_subnet" {
  vpc_id                  = "${aws_vpc.habitat_branch_lab_vpc.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "${data.aws_availability_zones.available.names[0]}"


  tags {
    Name = "${var.tag_name}_habitat_branch_lab_subnet-${var.tag_application}"
  }
}
////////////////////////////////
// Instance Data

data "aws_ami" "centos" {
  most_recent = true

  filter {
    name   = "name"
    values = ["chef-highperf-centos7-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["446539779517"]
}

data "aws_ami" "windows_node" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Windows_Server-2016-English-Full-Base*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["801119661308"]
}