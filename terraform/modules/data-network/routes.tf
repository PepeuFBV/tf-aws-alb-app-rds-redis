resource "aws_route_table" "data_public_infra" {
  vpc_id = aws_vpc.data.id

  tags = {
    Name = "${var.project_name}-data-public-rt"
  }
}

resource "aws_route" "data_public_infra_internet" {
  route_table_id         = aws_route_table.data_public_infra.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.data.id
}

resource "aws_route_table_association" "data_public_infra_a" {
  subnet_id      = aws_subnet.data_public_infra_a.id
  route_table_id = aws_route_table.data_public_infra.id
}

resource "aws_route_table" "data_private" {
  vpc_id = aws_vpc.data.id

  tags = {
    Name = "${var.project_name}-data-private-rt"
  }
}

resource "aws_route" "data_private_nat" {
  route_table_id         = aws_route_table.data_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.data.id
}

resource "aws_route_table_association" "data_private_a" {
  subnet_id      = aws_subnet.data_private_a.id
  route_table_id = aws_route_table.data_private.id
}

resource "aws_route_table_association" "data_private_b" {
  subnet_id      = aws_subnet.data_private_b.id
  route_table_id = aws_route_table.data_private.id
}
