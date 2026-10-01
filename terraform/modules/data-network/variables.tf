variable "project_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "private_subnet_a_cidr" {
  type = string
}

variable "private_subnet_b_cidr" {
  type = string
}

variable "public_infra_subnet_a_cidr" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}
