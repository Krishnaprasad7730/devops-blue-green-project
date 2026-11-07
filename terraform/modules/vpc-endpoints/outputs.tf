output "endpoint_security_group_id" {
  description = "Security group for VPC endpoints"
  value       = aws_security_group.endpoints.id
}

output "interface_endpoint_ids" {
  description = "Interface endpoint IDs"
  value       = { for key, endpoint in aws_vpc_endpoint.interface : key => endpoint.id }
}

output "s3_endpoint_id" {
  description = "S3 gateway endpoint ID"
  value       = aws_vpc_endpoint.s3.id
}

