resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Security group for the Application Load Balancer"
  vpc_id      = var.application_vpc_id

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

resource "aws_security_group" "application" {
  name        = "${var.project_name}-application-sg"
  description = "Security group for application EC2 instances"
  vpc_id      = var.application_vpc_id

  tags = {
    Name = "${var.project_name}-application-sg"
  }
}

resource "aws_security_group" "postgres" {
  name        = "${var.project_name}-postgres-sg"
  description = "Security group for PostgreSQL"
  vpc_id      = var.data_vpc_id

  tags = {
    Name = "${var.project_name}-postgres-sg"
  }
}

resource "aws_security_group" "redis" {
  name        = "${var.project_name}-redis-sg"
  description = "Security group for Redis"
  vpc_id      = var.data_vpc_id

  tags = {
    Name = "${var.project_name}-redis-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"

  description = "Allow HTTP from the Internet"
}

resource "aws_vpc_security_group_ingress_rule" "application_from_alb" {
  security_group_id            = aws_security_group.application.id
  referenced_security_group_id = aws_security_group.alb.id

  from_port   = var.application_port
  to_port     = var.application_port
  ip_protocol = "tcp"

  description = "Allow application traffic from the ALB"
}

resource "aws_vpc_security_group_ingress_rule" "postgres_from_application" {
  security_group_id            = aws_security_group.postgres.id
  referenced_security_group_id = aws_security_group.application.id

  from_port   = 5432
  to_port     = 5432
  ip_protocol = "tcp"

  description = "Allow PostgreSQL traffic from application instances"
}

resource "aws_vpc_security_group_ingress_rule" "redis_from_application" {
  security_group_id            = aws_security_group.redis.id
  referenced_security_group_id = aws_security_group.application.id

  from_port   = 6379
  to_port     = 6379
  ip_protocol = "tcp"

  description = "Allow Redis traffic from application instances"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_application" {
  security_group_id            = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.application.id

  from_port   = var.application_port
  to_port     = var.application_port
  ip_protocol = "tcp"

  description = "Allow ALB traffic to application instances"
}

resource "aws_vpc_security_group_egress_rule" "application_to_postgres" {
  security_group_id            = aws_security_group.application.id
  referenced_security_group_id = aws_security_group.postgres.id

  from_port   = 5432
  to_port     = 5432
  ip_protocol = "tcp"

  description = "Allow application traffic to PostgreSQL"
}

resource "aws_vpc_security_group_egress_rule" "application_to_redis" {
  security_group_id            = aws_security_group.application.id
  referenced_security_group_id = aws_security_group.redis.id

  from_port   = 6379
  to_port     = 6379
  ip_protocol = "tcp"

  description = "Allow application traffic to Redis"
}
