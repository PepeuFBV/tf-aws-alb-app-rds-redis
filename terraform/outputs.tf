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
