data "aws_availability_zones" "available" {}

# VPC
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge({
    Name        = "${var.namespace}-${var.name}"
  }, var.common_tags)
  lifecycle {
    ignore_changes = [tags.created_by]
  }
}

# Subnets
# Internet Gateway for Public Subnet
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = merge({
    Name        = "${var.namespace}-${var.name}"
  }, var.common_tags)
  lifecycle {
    ignore_changes = [tags.created_by]
  }
}

# Elastic-IP (eip) for NAT
resource "aws_eip" "this" {
  vpc        = true
  tags = merge({
    Name        = "${var.namespace}-${var.name}"
  }, var.common_tags)
  lifecycle {
    ignore_changes = [tags.created_by]
  }
}

# NAT
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.this.id
  subnet_id     = element(aws_subnet.public.*.id, 0)

  tags = merge({
    Name        = "${var.namespace}-${var.name}"
  }, var.common_tags)
  lifecycle {
    ignore_changes = [tags.created_by]
  }
}

# Public subnet
resource "aws_subnet" "public" {
  count = length(var.public_subnets_cidr)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = element(var.public_subnets_cidr, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = merge({
    Name        = "${var.namespace}-${element(local.availability_zones, count.index)}-public"
  }, var.common_tags)
  lifecycle {
    ignore_changes = [tags.created_by]
  }
}


# Private Subnet
resource "aws_subnet" "private" {
  count = length(var.public_subnets_cidr)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = element(var.private_subnets_cidr, count.index)
  availability_zone       = element(local.availability_zones, count.index)
  map_public_ip_on_launch = false

  tags = merge({
    Name        = "${var.namespace}-${element(local.availability_zones, count.index)}-private"
  }, var.common_tags)
  lifecycle {
    ignore_changes = [tags.created_by]
  }
}


# Routing tables to route traffic for Private Subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = merge({
    Name        = "${var.namespace}-${var.name}-private"
  }, var.common_tags)
  lifecycle {
    ignore_changes = [tags.created_by]
  }
}

# Routing tables to route traffic for Public Subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge({
    Name        = "${var.namespace}-${var.name}-public"
  }, var.common_tags)
  lifecycle {
    ignore_changes = [tags.created_by]
  }
}

# Route for Internet Gateway
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

# Route for NAT
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# Route table associations for both Public & Private Subnets
resource "aws_route_table_association" "public" {
  count = length(var.public_subnets_cidr)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets_cidr)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

# Default Security Group of VPC
resource "aws_security_group" "default" {
  name        = "${var.namespace}-default"
  description = "Default SG to allow traffic from the VPC"
  vpc_id      = aws_vpc.this.id
  depends_on = [
    aws_vpc.this
  ]

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = "true"
  }

  tags = merge({
    Name        = "${var.namespace}-${var.name}-default"
  }, var.common_tags)
  lifecycle {
    ignore_changes = [tags.created_by]
  }
}
