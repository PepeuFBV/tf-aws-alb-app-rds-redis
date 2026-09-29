resource "aws_vpc" "application" {
  cidr_block = var.application_vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-application-vpc"
  }
}