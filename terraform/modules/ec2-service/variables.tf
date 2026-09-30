variable "project_name" {
  type = string
}

variable "service_name" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "associate_public_ip_address" {
  type    = bool
  default = false
}

variable "key_name" {
  type    = string
  default = null
}

variable "user_data" {
  type    = string
  default = null
}
