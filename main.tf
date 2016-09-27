provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

/*
 * VPC basics
 */
resource "aws_vpc" "vpc_stage" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = "true"
  enable_dns_support = "true"

  tags {
    Name = "vpc-${var.vpc_name}"
    Env = "${var.environment}"
    Stack = "${var.stack}"
    Terraform = "true"
  }
}

# DHCP
resource "aws_vpc_dhcp_options" "vpc_dhcp_options" {
  domain_name = "${var.vpc_r53_zone}"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags {
    Name = "dhcp-options-${var.environment}-${var.stack}"
    Env = "${var.environment}"
    Stack = "${var.stack}"
    Terraform = "true"
  }
}

resource "aws_vpc_dhcp_options_association" "vpc_dns_association_stage" {
  vpc_id = "${aws_vpc.vpc_stage.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.vpc_dhcp_options.id}"
}

# Internet Gateway
resource "aws_internet_gateway" "igw_vpc_stage" {
  vpc_id = "${aws_vpc.vpc_stage.id}"

  tags {
    Name = "igw-${var.environment}"
    Env = "${var.environment}"
    Stack = "${var.stack}"
    Terraform = "true"
  }
}

/*
 * VPC Subnets
 */
resource "aws_subnet" "subnet_public" {
  vpc_id = "${aws_vpc.vpc_stage.id}"
  cidr_block = "${lookup(var.subnets, "public_${count.index}")}" 
  availability_zone = "${lookup(var.az, "${count.index}")}" 

  tags {
    Name = "subnet_public"
    Env = "${var.environment}"
    Stack = "${var.stack}"
    Terraform = "true"
  }

  count = 2
}

resource "aws_subnet" "subnet_private" {
  vpc_id = "${aws_vpc.vpc_stage.id}"
  cidr_block = "${lookup(var.subnets, "private_${count.index}")}" 
  availability_zone = "${lookup(var.az, "${count.index}")}" 

  tags {
    Name = "subnet_private"
    Env = "${var.environment}"
    Stack = "${var.stack}"
    Terraform = "true"
  }

  count = 2
}

/*
 * VPC Nat and routes tables
 */
resource "aws_eip" "eip_nat_gw_public" {
  vpc = true

  count = 2
}

resource "aws_nat_gateway" "nat_gw_public" {
  allocation_id = "${element(aws_eip.eip_nat_gw_public.*.id, count.index)}"
  subnet_id = "${element(aws_subnet.subnet_public.*.id, count.index)}"
  depends_on = ["aws_internet_gateway.igw_vpc_stage"]

  count = 2
}

resource "aws_route_table" "route_table_public" {
  vpc_id = "${aws_vpc.vpc_stage.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw_vpc_stage.id}"
  }

  tags {
    Name = "route_table_public"
    Env = "${var.environment}"
    Stack = "${var.stack}"
    Terraform = "true"
  }
}

resource "aws_route_table_association" "route_table_association_public" {
    subnet_id = "${element(aws_subnet.subnet_public.*.id, count.index)}"
    route_table_id = "${aws_route_table.route_table_public.id}"

    count = 2
}

resource "aws_route_table" "route_table_private" {
  vpc_id = "${aws_vpc.vpc_stage.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${element(aws_nat_gateway.nat_gw_public.*.id, count.index)}"
  }

  tags {
    Name = "route_table_private"
    Env = "${var.environment}"
    Stack = "${var.stack}"
    Terraform = "true"
  }

  count = 2
}

resource "aws_route_table_association" "route_table_association_private" {
    subnet_id = "${element(aws_subnet.subnet_private.*.id, count.index)}"
    route_table_id = "${element(aws_route_table.route_table_private.*.id, count.index)}"
    
    count = 2
}

/*
 * RDS Subnets
 */
 resource "aws_db_subnet_group" "db_subnet_group_private" {
  name = "db_subnet_group_private"
  subnet_ids = ["${aws_subnet.subnet_private.*.id}"]
  tags {
    Name = "db_subnet_group_private"
    Env = "${var.environment}"
    Stack = "${var.stack}"
    Terraform = "true"
  }
}