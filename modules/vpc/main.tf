# ---------------------------------------------------------------------
# Variables

variable "region" {}
variable "private_vpc_cidr" {}
variable "public_subnet_a_cidr" {}
variable "public_subnet_c_cidr" {}
variable "private_subnet_a_cidr" {}
variable "private_subnet_c_cidr" {}

# ---------------------------------------------------------------------
# output

output "vpc_main_id" {
  value = aws_vpc.vpc_main.id
}

output "public_subnet_a_id" {
  value = aws_subnet.public_subnet_a.id
}

output "public_subnet_c_id" {
  value = aws_subnet.public_subnet_c.id
}

output "private_subnet_a_id" {
  value = aws_subnet.private_subnet_a.id
}

output "private_subnet_c_id" {
  value = aws_subnet.private_subnet_c.id
}

output "nat_gateway_a" {
  value = aws_nat_gateway.nat_a
}

# ---------------------------------------------------------------------
# vpc

resource "aws_vpc" "vpc_main" {
  cidr_block = var.private_vpc_cidr
  tags = {
    Name = "example-vpc"
  }
}

# ---------------------------------------------------------------------
# subnet

resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.vpc_main.id
  cidr_block              = var.public_subnet_a_cidr
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "example-public-subnet-a"
  }
}

resource "aws_subnet" "public_subnet_c" {
  vpc_id                  = aws_vpc.vpc_main.id
  cidr_block              = var.public_subnet_c_cidr
  availability_zone       = "${var.region}c"
  map_public_ip_on_launch = true
  tags = {
    Name = "example-public-subnet-c"
  }
}
resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.vpc_main.id
  cidr_block        = var.private_subnet_a_cidr
  availability_zone = "${var.region}a"
  tags = {
    Name = "example-private-subnet-a"
  }
}

resource "aws_subnet" "private_subnet_c" {
  vpc_id            = aws_vpc.vpc_main.id
  cidr_block        = var.private_subnet_c_cidr
  availability_zone = "${var.region}c"
  tags = {
    Name = "example-private-subnet-c"
  }
}

# ---------------------------------------------------------------------
# Internet gateway

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_main.id

  tags = {
    Name = "example-igw"
  }
}

# ---------------------------------------------------------------------
# Nat gateway
resource "aws_eip" "eip_for_nat" {
  vpc = true

  tags = {
    Name = "example-eip-for-nat"
  }
}

resource "aws_nat_gateway" "nat_a" {
  allocation_id = aws_eip.eip_for_nat.id
  subnet_id     = aws_subnet.public_subnet_a.id
  tags = {
    Name = "example-nat"
  }
}

# ---------------------------------------------------------------------
# Route table for Internet gateway

resource "aws_route_table" "vpc_public_rtb" {
  vpc_id = aws_vpc.vpc_main.id

  tags = {
    Name = "example-rtb-public"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.vpc_public_rtb.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public_subnet_association_a" {
  route_table_id = aws_route_table.vpc_public_rtb.id
  subnet_id      = aws_subnet.public_subnet_a.id
}

resource "aws_route_table_association" "public_subnet_association_c" {
  route_table_id = aws_route_table.vpc_public_rtb.id
  subnet_id      = aws_subnet.public_subnet_c.id
}

# ---------------------------------------------------------------------
# Route table for Nat gateway

resource "aws_route_table" "vpc_private_rtb" {
  vpc_id = aws_vpc.vpc_main.id

  tags = {
    Name = "example-rtb-private"
  }
}

resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.vpc_private_rtb.id
  gateway_id             = aws_nat_gateway.nat_a.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "private_subnet_association_a" {
  route_table_id = aws_route_table.vpc_private_rtb.id
  subnet_id      = aws_subnet.private_subnet_a.id
}

resource "aws_route_table_association" "private_subnet_association_c" {
  route_table_id = aws_route_table.vpc_private_rtb.id
  subnet_id      = aws_subnet.private_subnet_c.id
}
