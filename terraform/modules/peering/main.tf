resource "aws_vpc_peering_connection" "application_data" {
  vpc_id      = var.application_vpc_id
  peer_vpc_id = var.data_vpc_id

  auto_accept = true

  tags = {
    Name = "${var.project_name}-application-data-peering"
  }
}

resource "aws_route" "application_to_data" {
  route_table_id            = var.application_route_table_id
  destination_cidr_block    = var.data_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.application_data.id
}

resource "aws_route" "data_to_application" {
  route_table_id            = var.data_route_table_id
  destination_cidr_block    = var.application_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.application_data.id
}
