resource "aws_route_table" "application_public" {
  vpc_id = aws_vpc.application.id

  tags = {
    Name = "${var.project_name}-application-public-rt"
  }
}

resource "aws_route" "application_public_internet" {
  route_table_id         = aws_route_table.application_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.application.id
}

resource "aws_route_table_association" "application_public_a" {
  subnet_id      = aws_subnet.application_public_a.id
  route_table_id = aws_route_table.application_public.id
}

resource "aws_route_table_association" "application_public_b" {
  subnet_id      = aws_subnet.application_public_b.id
  route_table_id = aws_route_table.application_public.id
}
