# AWS Multi-VPC Web Architecture with Terraform

## About

This project implements an AWS infrastructure using Terraform for a web application composed of an application layer, PostgreSQL database, and Redis service.

The architecture separates the application and data layers into two distinct VPCs. The web application is exposed to the Internet through an Application Load Balancer (ALB), while PostgreSQL and Redis remain private and are accessible only through controlled communication between the VPCs.

The main goals of the project are to explore AWS networking, infrastructure security, and Infrastructure as Code concepts while building the architecture incrementally.

## Requirements

The infrastructure must satisfy the following requirements:

- Use two distinct VPCs with non-overlapping IPv4 CIDR blocks.
- Deploy the web application across two public subnets.
- Expose the application to the Internet through an Application Load Balancer.
- Ensure the application subnets can support at least 20 instances.
- Place PostgreSQL and Redis in private subnets inside the data VPC.
- Ensure the data subnets can support at least 25 resources.
- Keep PostgreSQL and Redis inaccessible directly from the Internet.
- Run PostgreSQL and Redis in separate execution environments.
- Allow communication from the application to PostgreSQL through VPC Peering.
- Allow communication from the application to Redis through VPC Peering.
- Control traffic between components using Security Groups.
- Configure route tables with only the routes required by the architecture.
- Allow private resources to access the Internet when required for updates.
- Prevent direct SSH access from the Internet to resources that do not require it.
- Use a Jump Host for administrative access.
- Design the network with future expansion in mind.
