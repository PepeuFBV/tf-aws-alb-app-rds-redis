resource "aws_vpc" "application" {
  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-application-vpc"
  }
}

resource "aws_subnet" "application_public_a" {
  vpc_id = aws_vpc.application.id

  cidr_block        = var.public_subnet_a_cidr
  availability_zone = var.availability_zones[0]

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-application-public-a"
  }
}

resource "aws_subnet" "application_public_b" {
  vpc_id = aws_vpc.application.id

  cidr_block        = var.public_subnet_b_cidr
  availability_zone = var.availability_zones[1]

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-application-public-b"
  }
}

resource "aws_internet_gateway" "application" {
  vpc_id = aws_vpc.application.id

  tags = {
    Name = "${var.project_name}-application-igw"
  }
}
