output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = { for key, subnet in aws_subnet.public : key => subnet.id }
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = { for key, subnet in aws_subnet.private : key => subnet.id }
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_id" {
  description = "NAT Gateway ID, if enabled"
  value       = try(aws_nat_gateway.main[0].id, null)
}
output "private_route_table_ids" {
  description = "Private route table IDs"
  value       = [for route_table in aws_route_table.private : route_table.id]
}
