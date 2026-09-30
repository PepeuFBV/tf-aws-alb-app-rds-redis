module "application_network" {
  source = "./modules/application-network"

  project_name         = var.project_name
  vpc_cidr             = var.application_vpc_cidr
  public_subnet_a_cidr = var.application_public_subnet_a_cidr
  public_subnet_b_cidr = var.application_public_subnet_b_cidr
  availability_zones   = data.aws_availability_zones.available.names
}

module "data_network" {
  source = "./modules/data-network"

  project_name               = var.project_name
  vpc_cidr                   = var.data_vpc_cidr
  private_subnet_a_cidr      = var.data_private_subnet_a_cidr
  private_subnet_b_cidr      = var.data_private_subnet_b_cidr
  public_infra_subnet_a_cidr = var.data_public_infra_subnet_a_cidr
  availability_zones         = data.aws_availability_zones.available.names
}

module "peering" {
  source = "./modules/peering"

  project_name               = var.project_name
  application_vpc_id         = module.application_network.vpc_id
  data_vpc_id                = module.data_network.vpc_id
  application_route_table_id = module.application_network.public_route_table_id
  data_route_table_id        = module.data_network.private_route_table_id
  application_vpc_cidr       = var.application_vpc_cidr
  data_vpc_cidr              = var.data_vpc_cidr
}

module "security" {
  source = "./modules/security"

  project_name       = var.project_name
  application_vpc_id = module.application_network.vpc_id
  data_vpc_id        = module.data_network.vpc_id
  application_port   = var.application_port

  depends_on = [module.peering]
}


module "postgres_compute" {
  source = "./modules/ec2-service"

  project_name  = var.project_name
  service_name  = "postgres"
  ami_id        = data.aws_ami.ubuntu.id
  instance_type = var.postgres_instance_type
  subnet_id     = module.data_network.private_subnet_a_id

  security_group_ids = [
    module.security.postgres_security_group_id
  ]

  user_data = join("\n", [
    file("${path.root}/../services/bootstrap/install-docker.sh"),
    "mkdir -p /opt/postgres"
  ])
}

module "redis_compute" {
  source = "./modules/ec2-service"

  project_name  = var.project_name
  service_name  = "redis"
  ami_id        = data.aws_ami.ubuntu.id
  instance_type = var.redis_instance_type
  subnet_id     = module.data_network.private_subnet_b_id

  security_group_ids = [
    module.security.redis_security_group_id
  ]

  user_data = join("\n", [
    file("${path.root}/../services/bootstrap/install-docker.sh"),
    "mkdir -p /opt/redis"
  ])
}


module "application_compute_a" {
  source = "./modules/ec2-service"

  project_name  = var.project_name
  service_name  = "application-a"
  ami_id        = data.aws_ami.ubuntu.id
  instance_type = var.application_instance_type
  subnet_id     = module.application_network.public_subnet_a_id

  security_group_ids = [
    module.security.application_security_group_id
  ]

  associate_public_ip_address = true

  user_data = join("\n", [
    file("${path.root}/../services/bootstrap/install-docker.sh"),
    "mkdir -p /opt/app"
  ])
}

module "application_compute_b" {
  source = "./modules/ec2-service"

  project_name  = var.project_name
  service_name  = "application-b"
  ami_id        = data.aws_ami.ubuntu.id
  instance_type = var.application_instance_type
  subnet_id     = module.application_network.public_subnet_b_id

  security_group_ids = [
    module.security.application_security_group_id
  ]

  associate_public_ip_address = true

  user_data = join("\n", [
    file("${path.root}/../services/bootstrap/install-docker.sh"),
    "mkdir -p /opt/app"
  ])
}

module "application_load_balancer" {
  source = "./modules/application-load-balancer"

  project_name      = var.project_name
  vpc_id            = module.application_network.vpc_id
  application_port  = var.application_port
  security_group_id = module.security.alb_security_group_id

  subnet_ids = [
    module.application_network.public_subnet_a_id,
    module.application_network.public_subnet_b_id
  ]

  target_instance_ids = [
    module.application_compute_a.instance_id,
    module.application_compute_b.instance_id
  ]
}
