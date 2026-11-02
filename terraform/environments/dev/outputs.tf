# VPC ID
output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

# VPC CIDR
output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

# VPC ARN
output "vpc_arn" {
  description = "ARN of the created VPC"
  value       = aws_vpc.main.arn
}
