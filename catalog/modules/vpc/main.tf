################################################################################
# VPC
################################################################################

resource "aws_vpc" "this" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = var.name }
}

################################################################################
# Internet Gateway
################################################################################

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = { Name = "${var.name}-igw" }
}

################################################################################
# Public Subnets
################################################################################

resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    { Name = "${var.name}-public-${var.azs[count.index]}" },
    var.public_subnet_tags,
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = { Name = "${var.name}-public" }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

################################################################################
# Private Subnets
################################################################################

resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(
    { Name = "${var.name}-private-${var.azs[count.index]}" },
    var.private_subnet_tags,
  )
}

resource "aws_route_table" "private" {
  count = var.enable_nat && !var.single_nat ? length(var.private_subnets) : 1

  vpc_id = aws_vpc.this.id

  tags = {
    Name = var.single_nat || !var.enable_nat ? "${var.name}-private" : "${var.name}-private-${var.azs[count.index]}"
  }
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[var.enable_nat && !var.single_nat ? count.index : 0].id
}

################################################################################
# Database / Isolated Subnets (NO internet route)
################################################################################

resource "aws_subnet" "database" {
  count = length(var.database_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.database_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(
    { Name = "${var.name}-database-${var.azs[count.index]}" },
    var.database_subnet_tags,
  )
}

resource "aws_route_table" "database" {
  count = length(var.database_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = { Name = "${var.name}-database" }
}

resource "aws_route_table_association" "database" {
  count = length(var.database_subnets)

  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database[0].id
}

# RDS subnet group (automatically created from database subnets)
resource "aws_db_subnet_group" "this" {
  count = length(var.database_subnets) > 0 ? 1 : 0

  name        = var.name
  description = "Database subnet group for ${var.name}"
  subnet_ids  = aws_subnet.database[*].id

  tags = { Name = var.name }
}

################################################################################
# NAT Gateway (optional, cost: $0.045/hr + $0.045/GB)
################################################################################

resource "aws_eip" "nat" {
  count = var.enable_nat ? (var.single_nat ? 1 : length(var.public_subnets)) : 0

  domain = "vpc"

  tags = {
    Name = var.single_nat ? "${var.name}-nat" : "${var.name}-nat-${var.azs[count.index]}"
  }
}

resource "aws_nat_gateway" "this" {
  count = var.enable_nat ? (var.single_nat ? 1 : length(var.public_subnets)) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = var.single_nat ? "${var.name}-nat" : "${var.name}-nat-${var.azs[count.index]}"
  }

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route" "private_nat" {
  count = var.enable_nat ? (var.single_nat ? 1 : length(var.private_subnets)) : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[var.single_nat ? 0 : count.index].id
}
