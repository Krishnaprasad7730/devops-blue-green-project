# --------------------------------------------------
# EKS CLUSTER SECURITY GROUP
# --------------------------------------------------

resource "aws_security_group" "eks_cluster" {
  name        = "${var.project_name}-${var.environment}-eks-cluster-sg"
  description = "Security group for EKS control plane"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.project_name}-${var.environment}-eks-cluster-sg"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Allow worker nodes to communicate with EKS API
resource "aws_vpc_security_group_ingress_rule" "cluster_from_nodes" {
  security_group_id            = aws_security_group.eks_cluster.id
  referenced_security_group_id = aws_security_group.eks_nodes.id

  description = "Allow worker nodes to access EKS API"
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
}

# Allow outbound traffic from cluster
resource "aws_vpc_security_group_egress_rule" "cluster_egress" {
  security_group_id = aws_security_group.eks_cluster.id

  description = "Allow outbound traffic"
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}


# --------------------------------------------------
# EKS WORKER NODE SECURITY GROUP
# --------------------------------------------------

resource "aws_security_group" "eks_nodes" {
  name        = "${var.project_name}-${var.environment}-eks-node-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.project_name}-${var.environment}-eks-node-sg"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Allow communication between worker nodes
resource "aws_vpc_security_group_ingress_rule" "nodes_self" {
  security_group_id            = aws_security_group.eks_nodes.id
  referenced_security_group_id = aws_security_group.eks_nodes.id

  description = "Allow communication between worker nodes"
  ip_protocol = "-1"
}

# Allow EKS control plane to communicate with kubelet
resource "aws_vpc_security_group_ingress_rule" "nodes_from_cluster" {
  security_group_id            = aws_security_group.eks_nodes.id
  referenced_security_group_id = aws_security_group.eks_cluster.id

  description = "Allow EKS control plane to communicate with worker nodes"
  ip_protocol = "tcp"
  from_port   = 10250
  to_port     = 10250
}

# Allow application traffic from ALB to worker nodes
resource "aws_vpc_security_group_ingress_rule" "nodes_from_alb" {
  security_group_id            = aws_security_group.eks_nodes.id
  referenced_security_group_id = aws_security_group.alb.id

  description = "Allow application traffic from ALB"
  ip_protocol = "tcp"
  from_port   = 8000
  to_port     = 8000
}

# Allow outbound traffic from worker nodes
resource "aws_vpc_security_group_egress_rule" "nodes_egress" {
  security_group_id = aws_security_group.eks_nodes.id

  description = "Allow outbound traffic"
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}


# --------------------------------------------------
# APPLICATION LOAD BALANCER SECURITY GROUP
# --------------------------------------------------

resource "aws_security_group" "alb" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "Security group for application load balancer"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.project_name}-${var.environment}-alb-sg"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Allow public HTTP traffic
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id

  description = "Allow HTTP traffic"
  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
  cidr_ipv4   = "0.0.0.0/0"
}

# Allow public HTTPS traffic
resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb.id

  description = "Allow HTTPS traffic"
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_ipv4   = "0.0.0.0/0"
}

# Allow outbound traffic from ALB
resource "aws_vpc_security_group_egress_rule" "alb_egress" {
  security_group_id = aws_security_group.alb.id

  description = "Allow outbound traffic"
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}
