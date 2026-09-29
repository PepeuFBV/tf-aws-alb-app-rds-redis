resource "aws_vpc" "application" {
  cidr_block = var.application_vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-application-vpc"
  }
}

resource "aws_subnet" "application_public_a" {
  vpc_id = aws_vpc.application.id

  cidr_block        = var.application_public_subnet_a_cidr
  availability_zone = data.aws_availability_zones.available.names[0]

  map_public_ip_on_launch = true # able to assign public IPs to instances launched in this subnet, doesn't make it public by default yet

  tags = {
    Name = "${var.project_name}-application-public-a"
  }
}

resource "aws_subnet" "application_public_b" {
  vpc_id = aws_vpc.application.id

  cidr_block        = var.application_public_subnet_b_cidr
  availability_zone = data.aws_availability_zones.available.names[1]

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

resource "aws_route_table" "application_public" {
  vpc_id = aws_vpc.application.id

  route {
    cidr_block = "0.0.0.0/0" # any IPv4 address
    gateway_id = aws_internet_gateway.application.id
  }

  tags = {
    Name = "${var.project_name}-application-public-rt"
  }
}

resource "aws_route_table_association" "application_public_a" {
  subnet_id      = aws_subnet.application_public_a.id
  route_table_id = aws_route_table.application_public.id
}

resource "aws_route_table_association" "application_public_b" {
  subnet_id      = aws_subnet.application_public_b.id
  route_table_id = aws_route_table.application_public.id
}


resource "aws_vpc" "data" {
  cidr_block = var.data_vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-data-vpc"
  }
}

resource "aws_subnet" "data_private_a" {
  vpc_id = aws_vpc.data.id

  cidr_block        = var.data_private_subnet_a_cidr
  availability_zone = data.aws_availability_zones.available.names[0]

  map_public_ip_on_launch = false # prevents automatic assignment of public IPs to instances in this subnet

  tags = {
    Name = "${var.project_name}-data-private-a"
  }
}

resource "aws_subnet" "data_private_b" {
  vpc_id = aws_vpc.data.id

  cidr_block        = var.data_private_subnet_b_cidr
  availability_zone = data.aws_availability_zones.available.names[1]

  map_public_ip_on_launch = false # prevents automatic assignment of public IPs to instances in this subnet

  tags = {
    Name = "${var.project_name}-data-private-b"
  }
}


resource "aws_subnet" "data_public_infra_a" {
  vpc_id = aws_vpc.data.id

  cidr_block        = var.data_public_infra_subnet_a_cidr
  availability_zone = data.aws_availability_zones.available.names[0]

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

resource "aws_route_table" "data_public_infra" {
  vpc_id = aws_vpc.data.id

  route {
    cidr_block = "0.0.0.0/0" # any IPv4 address
    gateway_id = aws_internet_gateway.data.id
  }

  tags = {
    Name = "${var.project_name}-data-public-rt"
  }
}

resource "aws_route_table_association" "data_public_infra_a" {
  subnet_id      = aws_subnet.data_public_infra_a.id
  route_table_id = aws_route_table.data_public.id
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

  depends_on = [
    aws_internet_gateway.data
  ]
}

resource "aws_route_table" "data_private" {
  vpc_id = aws_vpc.data.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.data.id
  }

  tags = {
    Name = "${var.project_name}-data-private-rt"
  }
}

resource "aws_route_table_association" "data_private_a" {
  subnet_id      = aws_subnet.data_private_a.id
  route_table_id = aws_route_table.data_private.id
}

resource "aws_route_table_association" "data_private_b" {
  subnet_id      = aws_subnet.data_private_b.id
  route_table_id = aws_route_table.data_private.id
}
