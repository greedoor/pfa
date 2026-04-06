output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_version" {
  description = "EKS cluster version"
  value       = aws_eks_cluster.main.version
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.main.arn
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

output "analysis_node_group_id" {
  description = "Analysis node group ID"
  value       = aws_eks_node_group.analysis.id
}

output "analysis_node_group_arn" {
  description = "Analysis node group ARN"
  value       = aws_eks_node_group.analysis.arn
}

output "analysis_autoscaling_group_names" {
  description = "Autoscaling group names created for the analysis node group"
  value       = aws_eks_node_group.analysis.resources[0].autoscaling_groups[*].name
}

output "storage_node_group_id" {
  description = "Storage node group ID"
  value       = aws_eks_node_group.storage.id
}

output "storage_node_group_arn" {
  description = "Storage node group ARN"
  value       = aws_eks_node_group.storage.arn
}

output "storage_autoscaling_group_names" {
  description = "Autoscaling group names created for the storage node group"
  value       = aws_eks_node_group.storage.resources[0].autoscaling_groups[*].name
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA. Empty when IRSA is disabled."
  value       = var.create_oidc_provider ? aws_iam_openid_connect_provider.cluster[0].arn : ""
}
