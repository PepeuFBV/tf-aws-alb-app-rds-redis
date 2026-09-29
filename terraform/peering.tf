resource "aws_vpc_peering_connection" "application_data" {
  vpc_id      = aws_vpc.application.id
  peer_vpc_id = aws_vpc.data.id

  auto_accept = true

  tags = {
    Name = "${var.project_name}-application-data-peering"
  }
}

resource "aws_route_table" "application_public" {
  vpc_id = aws_vpc.application.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.application.id
  }

  route {
    cidr_block                = var.data_vpc_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.application_data.id
  }

  tags = {
    Name = "${var.project_name}-application-public-rt"
  }
}
