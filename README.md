# AWS Multi-VPC Web Architecture with Terraform

## About

This project implements an AWS infrastructure using Terraform for a web application composed of an application layer, PostgreSQL database, and Redis service.

The architecture separates the application and data layers into two distinct VPCs. The web application is exposed to the Internet through an Application Load Balancer (ALB), while PostgreSQL and Redis remain private and are accessible only through controlled communication between the VPCs.

The main goals of the project are to explore AWS networking, infrastructure security, and Infrastructure as Code concepts while building the architecture incrementally.
