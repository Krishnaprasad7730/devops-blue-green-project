module "vpc" {
  source = "../../modules/vpc"

  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr

  availability_zones = var.availability_zones

  enable_nat_gateway = var.enable_nat_gateway
}
module "iam" {
  source = "../../modules/iam"

  project_name = var.project_name
  environment  = var.environment
}
module "security" {
  source = "../../modules/security"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
}
module "eks" {
  source = "../../modules/eks"

  project_name = var.project_name
  environment  = var.environment

  cluster_version = "1.37"

  private_subnet_ids = values(module.vpc.private_subnet_ids)

  cluster_security_group_id = module.security.eks_cluster_security_group_id
  node_security_group_id    = module.security.eks_node_security_group_id

  cluster_role_arn = module.iam.eks_cluster_role_arn
  node_role_arn    = module.iam.eks_node_role_arn

  node_instance_types = ["t3.medium"]

  desired_size = 2
  min_size     = 1
  max_size     = 3

  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  cluster_enabled_log_types = []
}
module "ecr" {
  source = "../../modules/ecr"

  project_name = var.project_name
  environment  = var.environment

  repository_name = "employee-api"
}
module "vpc_endpoints" {
  source = "../../modules/vpc-endpoints"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region

  vpc_id = module.vpc.vpc_id

  vpc_cidr = module.vpc.vpc_cidr

  private_subnet_ids = values(module.vpc.private_subnet_ids)

  private_route_table_ids = module.vpc.private_route_table_ids
}
