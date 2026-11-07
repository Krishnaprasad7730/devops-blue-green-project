# --------------------------------------------------
# SECURITY GROUP FOR VPC ENDPOINTS
# --------------------------------------------------

resource "aws_security_group" "endpoints" {
  name        = "${var.project_name}-${var.environment}-vpce-sg"
  description = "Security group for VPC interface endpoints"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpce-sg"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_vpc_security_group_ingress_rule" "https_from_vpc" {
  security_group_id = aws_security_group.endpoints.id

  description = "Allow HTTPS from VPC"
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_ipv4   = var.vpc_cidr
}

resource "aws_vpc_security_group_egress_rule" "endpoint_egress" {
  security_group_id = aws_security_group.endpoints.id

  description = "Allow outbound traffic"
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}


# --------------------------------------------------
# INTERFACE ENDPOINTS
# --------------------------------------------------

locals {
  interface_endpoints = toset([
    "ecr.api",
    "ecr.dkr",
    "ec2",
    "sts"
  ])
}

resource "aws_vpc_endpoint" "interface" {
  for_each = local.interface_endpoints

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.${each.value}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.endpoints.id]
  private_dns_enabled = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-${each.value}-endpoint"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}


# --------------------------------------------------
# S3 GATEWAY ENDPOINT
# --------------------------------------------------

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = var.private_route_table_ids

  tags = {
    Name        = "${var.project_name}-${var.environment}-s3-endpoint"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
