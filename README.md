# AWS Multi-VPC Web Architecture with Terraform

This project implements an AWS infrastructure using Terraform for a web application composed of an application layer, PostgreSQL database, and Redis service.

The architecture separates the application and data layers into two distinct VPCs. The web application is exposed to the Internet through an Application Load Balancer (ALB), while PostgreSQL and Redis remain private and communicate with the application through VPC Peering.

Application, PostgreSQL, and Redis services run on EC2 instances using Docker and Docker Compose.

The project is developed incrementally to explore AWS networking, infrastructure security, Docker-based deployments, and Infrastructure as Code concepts.

## Documentation

- [Architecture and project requirements](docs/architecture.md)
- [Networking, routing, and VPC Peering](docs/networking.md)
- [Security Groups and traffic flow](docs/security.md)
- [AWS resources and compute model](docs/infrastructure.md)

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.