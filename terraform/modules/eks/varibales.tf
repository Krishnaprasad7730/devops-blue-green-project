variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.37"
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for EKS"
  type        = list(string)
}

variable "cluster_security_group_id" {
  description = "EKS cluster security group ID"
  type        = string
}

variable "node_security_group_id" {
  description = "EKS node security group ID"
  type        = string
}

variable "cluster_role_arn" {
  description = "EKS cluster IAM role ARN"
  type        = string
}

variable "node_role_arn" {
  description = "EKS node IAM role ARN"
  type        = string
}

variable "node_instance_types" {
  description = "EC2 instance types for worker nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 3
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDR ranges allowed to access the public EKS API endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_enabled_log_types" {
  description = "EKS control plane log types"
  type        = list(string)
  default     = []
}
