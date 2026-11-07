variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "repository_name" {
  description = "ECR repository name"
  type        = string
  default     = "employee-api"
}
