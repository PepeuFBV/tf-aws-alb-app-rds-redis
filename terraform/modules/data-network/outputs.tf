output "vpc_id" {
  value = aws_vpc.data.id
}

output "private_subnet_a_id" {
  value = aws_subnet.data_private_a.id
}

output "private_subnet_b_id" {
  value = aws_subnet.data_private_b.id
}

output "public_infra_subnet_a_id" {
  value = aws_subnet.data_public_infra_a.id
}

output "private_route_table_id" {
  value = aws_route_table.data_private.id
}
