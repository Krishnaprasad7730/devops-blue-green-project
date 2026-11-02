variable "project_name" {
  description = "Name of the DevOps project"
  type        = string
  default     = "devops-blue-green"
}

variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "ap-south-2"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "enable_nat_gateway" {
  description = "Whether to enable NAT Gateway"
  type        = bool
  default     = false
}
