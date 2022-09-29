# VPC
resource "aws_vpc" "vpc" {
  count = local.enabled
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.namespace}-vpc"
    Environment = var.namespace
  }
}

# Subnets
# Internet Gateway for Public Subnet
resource "aws_internet_gateway" "ig" {
  count = local.enabled
  vpc_id = aws_vpc.vpc[0].id
  tags = {
    Name        = "${var.namespace}-igw"
    Environment = var.namespace
  }
}

# Elastic-IP (eip) for NAT
resource "aws_eip" "nat_eip" {
  count = local.enabled
  vpc        = true
  tags = {
    Name        = "${var.namespace}-nat-eip"
    Environment = var.namespace
  }
}

# NAT
resource "aws_nat_gateway" "nat" {
  count = local.enabled
  allocation_id = aws_eip.nat_eip[0].id
  subnet_id     = element(aws_subnet.public_subnet.*.id, 0)

  tags = {
    Name        = "nat"
    Environment = "${var.namespace}"
  }
}

# Public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc[0].id
  count                   = local.enabled == 1 ? length(var.public_subnets_cidr) : 0
  cidr_block              = element(var.public_subnets_cidr, count.index)
  availability_zone       = element(local.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.namespace}-${element(local.availability_zones, count.index)}-public-subnet"
    Environment = "${var.namespace}"
  }
}


# Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc[0].id
  count                   = local.enabled == 1 ? length(var.private_subnets_cidr) : 0
  cidr_block              = element(var.private_subnets_cidr, count.index)
  availability_zone       = element(local.availability_zones, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.namespace}-${element(local.availability_zones, count.index)}-private-subnet"
    Environment = "${var.namespace}"
  }
}


# Routing tables to route traffic for Private Subnet
resource "aws_route_table" "private" {
  count = local.enabled
  vpc_id = aws_vpc.vpc[0].id

  tags = {
    Name        = "${var.namespace}-private-route-table"
    Environment = "${var.namespace}"
  }
}

# Routing tables to route traffic for Public Subnet
resource "aws_route_table" "public" {
  count = local.enabled
  vpc_id = aws_vpc.vpc[0].id

  tags = {
    Name        = "${var.namespace}-public-route-table"
    Environment = "${var.namespace}"
  }
}

# Route for Internet Gateway
resource "aws_route" "public_internet_gateway" {
  count = local.enabled
  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig[0].id
}

# Route for NAT
resource "aws_route" "private_nat_gateway" {
  count = local.enabled
  route_table_id         = aws_route_table.private[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[0].id
}

# Route table associations for both Public & Private Subnets
resource "aws_route_table_association" "public" {
  count          = local.enabled == 1 ? length(var.public_subnets_cidr) : 0
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table_association" "private" {
  count          = local.enabled == 1 ? length(var.private_subnets_cidr) : 0
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private[0].id
}

# Default Security Group of VPC
resource "aws_security_group" "default" {
  count = local.enabled
  name        = "${var.namespace}-default-sg"
  description = "Default SG to allow traffic from the VPC"
  vpc_id      = aws_vpc.vpc[0].id
  depends_on = [
    aws_vpc.vpc
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

  tags = {
    Environment = "${var.namespace}"
  }
}
