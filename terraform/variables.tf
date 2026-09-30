variable "aws_region" {
  description = "AWS region where the infrastructure will be deployed"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "tf-aws-alb-app-rds-redis"
}


variable "application_vpc_cidr" {
  description = "CIDR block for the application VPC"
  type        = string
  default     = "10.0.0.0/24"
}

variable "application_public_subnet_a_cidr" {
  description = "CIDR block for application public subnet A"
  type        = string
  default     = "10.0.0.0/26"
}

variable "application_public_subnet_b_cidr" {
  description = "CIDR block for application public subnet B"
  type        = string
  default     = "10.0.0.64/26"
}


variable "data_vpc_cidr" {
  description = "CIDR block for the data VPC"
  type        = string
  default     = "10.0.1.0/24"
}

variable "data_private_subnet_a_cidr" {
  description = "CIDR block for data private subnet A"
  type        = string
  default     = "10.0.1.0/26"
}

variable "data_private_subnet_b_cidr" {
  description = "CIDR block for data private subnet B"
  type        = string
  default     = "10.0.1.64/26"
}


variable "data_public_infra_subnet_a_cidr" {
  description = "CIDR block for the public infrastructure subnet in the data VPC"
  type        = string
  default     = "10.0.1.128/28"
}


variable "application_port" {
  description = "Port exposed by the web application"
  type        = number
  default     = 8080
}

variable "postgres_instance_type" {
  description = "EC2 instance type used by PostgreSQL"
  type        = string
  default     = "t3.micro"
}
