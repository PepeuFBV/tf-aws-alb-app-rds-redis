output "application_vpc_id" {
  description = "The ID of the application VPC"
  value       = aws_vpc.application.id
}
