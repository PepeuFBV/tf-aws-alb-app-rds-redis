output "application_vpc_id" {
  description = "The ID of the application VPC"
  value       = module.application_network.vpc_id
}

output "application_public_subnet_a_id" {
  description = "ID of application public subnet A"
  value       = module.application_network.public_subnet_a_id
}

output "application_public_subnet_b_id" {
  description = "ID of application public subnet B"
  value       = module.application_network.public_subnet_b_id
}


output "data_vpc_id" {
  description = "ID of the data VPC"
  value       = module.data_network.vpc_id
}

output "data_private_subnet_a_id" {
  description = "ID of data private subnet A"
  value       = module.data_network.private_subnet_a_id
}

output "data_private_subnet_b_id" {
  description = "ID of data private subnet B"
  value       = module.data_network.private_subnet_b_id
}


output "data_public_infra_subnet_a_id" {
  description = "ID of the public infrastructure subnet in the data VPC"
  value       = module.data_network.public_infra_subnet_a_id
}


output "application_data_peering_id" {
  description = "ID of the VPC peering connection between application and data VPCs"
  value       = module.peering.id
}


output "postgres_instance_id" {
  description = "ID of the PostgreSQL EC2 instance"
  value       = module.postgres_compute.instance_id
}

output "postgres_private_ip" {
  description = "Private IPv4 address of the PostgreSQL EC2 instance"
  value       = module.postgres_compute.private_ip
}