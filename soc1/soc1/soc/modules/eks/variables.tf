variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
}

variable "management_subnet_ids" {
  description = "List of public management subnet IDs"
  type        = list(string)
}

variable "soc_subnet_ids" {
  description = "List of private SOC subnet IDs"
  type        = list(string)
}

variable "security_group_id" {
  description = "Shared security group ID for the EKS cluster"
  type        = string
}

variable "analysis_desired_nodes" {
  description = "Desired number of analysis nodes"
  type        = number
}

variable "analysis_min_nodes" {
  description = "Minimum number of analysis nodes"
  type        = number
}

variable "analysis_max_nodes" {
  description = "Maximum number of analysis nodes"
  type        = number
}

variable "analysis_instance_types" {
  description = "Instance types for the analysis node group"
  type        = list(string)
}

variable "analysis_disk_size" {
  description = "Disk size in GiB for analysis nodes"
  type        = number
}

variable "storage_desired_nodes" {
  description = "Desired number of storage nodes"
  type        = number
}

variable "storage_min_nodes" {
  description = "Minimum number of storage nodes"
  type        = number
}

variable "storage_max_nodes" {
  description = "Maximum number of storage nodes"
  type        = number
}

variable "storage_instance_types" {
  description = "Instance types for the storage node group"
  type        = list(string)
}

variable "storage_disk_size" {
  description = "Disk size in GiB for storage nodes"
  type        = number
}

variable "cluster_role_arn" {
  description = "ARN of the IAM role for the EKS cluster. Leave empty to create a dedicated role."
  type        = string
  default     = ""
}

variable "node_role_arn" {
  description = "ARN of the IAM role for the EKS nodes. Leave empty to create a dedicated role."
  type        = string
  default     = ""
}

variable "create_oidc_provider" {
  description = "Whether to create the IAM OIDC provider for IRSA"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Whether the EKS API server should be reachable from the public internet"
  type        = bool
  default     = true
}

variable "endpoint_private_access" {
  description = "Whether the EKS API server should be reachable from the VPC"
  type        = bool
  default     = true
}
