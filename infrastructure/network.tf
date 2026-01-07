#================================================
# VPC
#================================================
resource "aws_vpc" "handson" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "handson-vpc"
  }
}

#================================================
# Subnet
#================================================
resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.handson.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.az_a
  tags = {
    Name = "public-2a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.handson.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.az_b
  tags = {
    Name = "public-2b"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.handson.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = var.az_a
  tags = {
    Name = "private-2a"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.handson.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = var.az_b
  tags = {
    Name = "private-2b"
  }
}

resource "aws_subnet" "db_a" {
  vpc_id            = aws_vpc.handson.id
  cidr_block        = "10.0.21.0/24"
  availability_zone = var.az_a
  tags = {
    Name = "db-2a"
  }
}

resource "aws_subnet" "db_b" {
  vpc_id            = aws_vpc.handson.id
  cidr_block        = "10.0.22.0/24"
  availability_zone = var.az_b
  tags = {
    Name = "db-2b"
  }
}

#================================================
# Internet Gateway
#================================================
resource "aws_internet_gateway" "handson" {
  vpc_id = aws_vpc.handson.id
  tags = {
    Name = "handson-igw"
  }
}

#================================================
# NAT Gateway
#================================================
resource "aws_eip" "nat_a" {

  depends_on = [aws_internet_gateway.handson]
}

resource "aws_nat_gateway" "nat_a" {
  allocation_id = aws_eip.nat_a.id
  subnet_id     = aws_subnet.public_a.id
  tags = {
    Name = "nat-2a"
  }
}

resource "aws_eip" "nat_b" {
  depends_on = [aws_internet_gateway.handson]
}

resource "aws_nat_gateway" "nat_b" {
  allocation_id = aws_eip.nat_b.id
  subnet_id     = aws_subnet.public_b.id
  tags = {
    Name = "nat-2b"
  }
}

#================================================
# Route Table
#================================================
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.handson.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.handson.id
  }
  tags = {
    Name = "public"
  }
}

resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.handson.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_a.id
  }
  tags = {
    Name = "private-a"
  }
}

resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.handson.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_b.id
  }
  tags = {
    Name = "private-b"
  }
}

#================================================
# Route Table Association
#================================================
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_a.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_b.id
}