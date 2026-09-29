output "application_vpc_id" {
  description = "The ID of the application VPC"
  value       = aws_vpc.application.id
}

output "application_public_subnet_a_id" {
  description = "ID of application public subnet A"
  value       = aws_subnet.application_public_a.id
}

output "application_public_subnet_b_id" {
  description = "ID of application public subnet B"
  value       = aws_subnet.application_public_b.id
}


output "data_vpc_id" {
  description = "ID of the data VPC"
  value       = aws_vpc.data.id
}

output "data_private_subnet_a_id" {
  description = "ID of data private subnet A"
  value       = aws_subnet.data_private_a.id
}

output "data_private_subnet_b_id" {
  description = "ID of data private subnet B"
  value       = aws_subnet.data_private_b.id
}


output "data_public_infra_subnet_a_id" {
  description = "ID of the public infrastructure subnet in the data VPC"
  value       = aws_subnet.data_public_infra_a.id
}
