variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "soc"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "soc_vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "management_public_subnet_cidrs" {
  description = "CIDR blocks for the public management subnets that host NAT gateways and public entry points."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "soc_private_subnet_cidrs" {
  description = "CIDR blocks for the private SOC subnets that host the EKS worker nodes."
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "workplace_private_subnet_cidrs" {
  description = "CIDR blocks for the private workplace subnets that host monitored workloads such as Linux, Windows, or AD instances."
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "soc-eks-cluster"
}

variable "kubernetes_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.29"
}

variable "desired_worker_nodes" {
  description = "Desired number of nodes in the analysis node group"
  type        = number
  default     = 3
}

variable "min_worker_nodes" {
  description = "Minimum number of nodes in the analysis node group"
  type        = number
  default     = 3
}

variable "max_worker_nodes" {
  description = "Maximum number of nodes in the analysis node group. The default aligns with the report's 3 to 10 elasticity target."
  type        = number
  default     = 10
}

variable "worker_instance_type" {
  description = "EC2 instance type for the analysis node group"
  type        = string
  default     = "c5.large"
}

variable "worker_disk_size" {
  description = "Disk size in GiB for analysis nodes"
  type        = number
  default     = 50
}

variable "desired_storage_nodes" {
  description = "Desired number of nodes in the storage node group"
  type        = number
  default     = 3
}

variable "min_storage_nodes" {
  description = "Minimum number of nodes in the storage node group"
  type        = number
  default     = 3
}

variable "max_storage_nodes" {
  description = "Maximum number of nodes in the storage node group"
  type        = number
  default     = 6
}

variable "storage_instance_type" {
  description = "EC2 instance type for the storage node group"
  type        = string
  default     = "t3.large"
}

variable "storage_disk_size" {
  description = "Disk size in GiB for storage nodes"
  type        = number
  default     = 150
}

variable "cluster_role_arn" {
  description = "ARN of an existing IAM role for the EKS cluster. Leave empty to create a dedicated role."
  type        = string
  default     = ""
}

variable "node_role_arn" {
  description = "ARN of an existing IAM role for the EKS node groups. Leave empty to create a dedicated role."
  type        = string
  default     = ""
}

variable "create_oidc_provider" {
  description = "Whether to create the IAM OIDC provider for IRSA. Set to false in restricted lab environments."
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Whether the EKS API server should be reachable from the public internet."
  type        = bool
  default     = true
}

variable "cluster_endpoint_private_access" {
  description = "Whether the EKS API server should be reachable from the VPC."
  type        = bool
  default     = true
}

variable "enable_vpc_flow_logs" {
  description = "Enable VPC Flow Logs to support network telemetry ingestion for the SOC."
  type        = bool
  default     = true
}

variable "flow_logs_retention_days" {
  description = "Retention period for the VPC Flow Logs CloudWatch log group."
  type        = number
  default     = 30
}

variable "single_nat_gateway" {
  description = "Use a single shared NAT gateway to reduce AWS Academy cost and quota usage."
  type        = bool
  default     = false
}
