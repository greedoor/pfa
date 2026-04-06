output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_cidr
}

output "management_public_subnet_ids" {
  description = "List of public management subnet IDs"
  value       = module.vpc.management_public_subnet_ids
}

output "soc_private_subnet_ids" {
  description = "List of private SOC subnet IDs"
  value       = module.vpc.soc_private_subnet_ids
}

output "workplace_private_subnet_ids" {
  description = "List of private workplace subnet IDs"
  value       = module.vpc.workplace_private_subnet_ids
}

output "vpc_flow_log_group_name" {
  description = "CloudWatch log group receiving VPC Flow Logs"
  value       = module.vpc.vpc_flow_log_group_name
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_version" {
  description = "EKS cluster version"
  value       = module.eks.cluster_version
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks.cluster_arn
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "analysis_node_group_id" {
  description = "Analysis node group ID"
  value       = module.eks.analysis_node_group_id
}

output "analysis_node_group_arn" {
  description = "Analysis node group ARN"
  value       = module.eks.analysis_node_group_arn
}

output "storage_node_group_id" {
  description = "Storage node group ID"
  value       = module.eks.storage_node_group_id
}

output "storage_node_group_arn" {
  description = "Storage node group ARN"
  value       = module.eks.storage_node_group_arn
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA"
  value       = module.eks.oidc_provider_arn
}

output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}
