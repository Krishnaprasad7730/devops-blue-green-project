output "eks_cluster_security_group_id" {
  description = "EKS cluster security group ID"
  value       = aws_security_group.eks_cluster.id
}

output "eks_node_security_group_id" {
  description = "EKS worker node security group ID"
  value       = aws_security_group.eks_nodes.id
}

output "alb_security_group_id" {
  description = "Application Load Balancer security group ID"
  value       = aws_security_group.alb.id
}
