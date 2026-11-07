# --------------------------------------------------
# EKS CLUSTER
# --------------------------------------------------

resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-${var.environment}-eks"
  role_arn = var.cluster_role_arn
  version  = var.cluster_version

  enabled_cluster_log_types = var.cluster_enabled_log_types

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  vpc_config {
    subnet_ids = var.private_subnet_ids

    security_group_ids = [
      var.cluster_security_group_id
    ]

    endpoint_private_access = true
    endpoint_public_access  = true

    public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-eks"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

}


# --------------------------------------------------
# EKS WORKER NODE LAUNCH TEMPLATE
# --------------------------------------------------

resource "aws_launch_template" "eks_nodes" {
  name_prefix = "${var.project_name}-${var.environment}-node-"

  vpc_security_group_ids = [
    var.node_security_group_id,
    var.cluster_security_group_id
  ]

  # Enforce IMDSv2
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  # Encrypted root volume
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 30
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "${var.project_name}-${var.environment}-eks-node"
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}


# --------------------------------------------------
# EKS MANAGED NODE GROUP
# --------------------------------------------------

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-${var.environment}-node-group"

  node_role_arn = var.node_role_arn

  subnet_ids = var.private_subnet_ids

  instance_types = var.node_instance_types
  capacity_type  = "ON_DEMAND"

  launch_template {
    id      = aws_launch_template.eks_nodes.id
    version = aws_launch_template.eks_nodes.latest_version
  }

  scaling_config {
    desired_size = var.desired_size
    min_size     = var.min_size
    max_size     = var.max_size
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    Environment = var.environment
    NodeGroup   = "application"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-node-group"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  depends_on = [
    aws_eks_cluster.main
  ]
}
