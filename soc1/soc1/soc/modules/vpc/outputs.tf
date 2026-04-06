output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

output "management_public_subnet_ids" {
  description = "List of public management subnet IDs"
  value       = aws_subnet.management_public[*].id
}

output "soc_private_subnet_ids" {
  description = "List of private SOC subnet IDs"
  value       = aws_subnet.soc_private[*].id
}

output "workplace_private_subnet_ids" {
  description = "List of private workplace subnet IDs"
  value       = aws_subnet.workplace_private[*].id
}

output "security_group_id" {
  description = "Shared security group ID for EKS"
  value       = aws_security_group.cluster.id
}

output "vpc_flow_log_group_name" {
  description = "CloudWatch log group name for VPC Flow Logs"
  value       = var.enable_vpc_flow_logs ? aws_cloudwatch_log_group.vpc_flow_logs[0].name : ""
}
