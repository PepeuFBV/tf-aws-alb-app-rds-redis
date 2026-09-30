resource "aws_vpc" "data" {
  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-data-vpc"
  }
}

resource "aws_subnet" "data_private_a" {
  vpc_id = aws_vpc.data.id

  cidr_block        = var.private_subnet_a_cidr
  availability_zone = var.availability_zones[0]

  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-data-private-a"
  }
}

resource "aws_subnet" "data_private_b" {
  vpc_id = aws_vpc.data.id

  cidr_block        = var.private_subnet_b_cidr
  availability_zone = var.availability_zones[1]

  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-data-private-b"
  }
}

resource "aws_subnet" "data_public_infra_a" {
  vpc_id = aws_vpc.data.id

  cidr_block        = var.public_infra_subnet_a_cidr
  availability_zone = var.availability_zones[0]

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-data-public-infra-a"
  }
}

resource "aws_internet_gateway" "data" {
  vpc_id = aws_vpc.data.id

  tags = {
    Name = "${var.project_name}-data-igw"
  }
}

resource "aws_eip" "data_nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-data-nat-eip"
  }
}

resource "aws_nat_gateway" "data" {
  allocation_id = aws_eip.data_nat.id
  subnet_id     = aws_subnet.data_public_infra_a.id

  tags = {
    Name = "${var.project_name}-data-nat"
  }

  depends_on = [aws_internet_gateway.data]
}
