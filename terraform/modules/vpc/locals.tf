locals {
  public_subnets = {
    public-1 = {
      cidr = "10.0.1.0/24"
      az   = var.availability_zones[0]
    }

    public-2 = {
      cidr = "10.0.2.0/24"
      az   = var.availability_zones[1]
    }
  }

  private_subnets = {
    private-1 = {
      cidr = "10.0.11.0/24"
      az   = var.availability_zones[0]
    }

    private-2 = {
      cidr = "10.0.12.0/24"
      az   = var.availability_zones[1]
    }
  }

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
