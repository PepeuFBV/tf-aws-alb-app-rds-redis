variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "application_port" {
  type = number
}

variable "target_instance_ids" {
  type = set(string)
}
