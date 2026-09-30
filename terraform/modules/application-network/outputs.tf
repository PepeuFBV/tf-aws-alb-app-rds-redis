output "vpc_id" {
  value = aws_vpc.application.id
}

output "public_subnet_a_id" {
  value = aws_subnet.application_public_a.id
}

output "public_subnet_b_id" {
  value = aws_subnet.application_public_b.id
}

output "public_route_table_id" {
  value = aws_route_table.application_public.id
}
