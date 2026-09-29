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
