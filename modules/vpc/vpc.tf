# VPC
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge({
    Name = var.name
  }, var.common_tags)
  lifecycle {
    ignore_changes = [tags.created_by]
  }
}

# Internet Gateway for Public Subnet
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = merge({
    Name = "${var.namespace}-${var.name}"
  }, var.common_tags)
  lifecycle {
    ignore_changes = [tags.created_by]
  }
}

# Elastic-IP (eip) for NAT
resource "aws_eip" "this" {
  for_each = var.az_to_subnets
  vpc = true
  tags = merge({
    Name = var.name
  }, var.common_tags)
  lifecycle {
    ignore_changes = [tags.created_by]
  }
}

# NAT
resource "aws_nat_gateway" "this" {
  for_each = var.az_to_subnets
  allocation_id = aws_eip.this[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = merge({
    Name = "${var.name}-${each.key}"
  }, var.common_tags)
  lifecycle {
    ignore_changes = [tags.created_by]
  }
}

# Public subnet
resource "aws_subnet" "public" {
  for_each = var.az_to_subnets
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value["public_cidr"]
  availability_zone       = each.key
  map_public_ip_on_launch = true
  tags = merge({
    Name = "public-${each.key}"
  }, var.common_tags)
  lifecycle {
    ignore_changes = [tags.created_by]
  }
}

# Private Subnet
resource "aws_subnet" "private" {
  for_each = var.az_to_subnets
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value["private_cidr"]
  availability_zone       = each.key
  map_public_ip_on_launch = false

  tags = merge({
    Name = "private-${each.key}"
  }, var.common_tags)
  lifecycle {
    ignore_changes = [tags.created_by]
  }
}

# Routing tables to route traffic for Public Subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge({
    Name = "${var.name}-public"
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

# Routing tables to route traffic for Private Subnet
resource "aws_route_table" "private" {
  for_each = var.az_to_subnets
  vpc_id = aws_vpc.this.id

  tags = merge({
    Name = "${var.name}-private-${each.key}"
  }, var.common_tags)
  lifecycle {
    ignore_changes = [tags.created_by]
  }
}

# Route for NAT
resource "aws_route" "private_nat_gateway" {
  for_each = var.az_to_subnets
  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[each.key].id
}

# Route table associations for both Public & Private Subnets
resource "aws_route_table_association" "public" {
  for_each = var.az_to_subnets
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  for_each = var.az_to_subnets
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}

# Default Security Group of VPC
resource "aws_security_group" "default" {
  name        = "${var.name}-default"
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
    Name = "${var.name}-default"
  }, var.common_tags)
  lifecycle {
    ignore_changes = [tags.created_by]
  }
}
