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
