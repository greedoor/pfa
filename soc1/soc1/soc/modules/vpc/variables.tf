variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "management_public_subnet_cidrs" {
  description = "CIDR blocks for the management public subnets"
  type        = list(string)
}

variable "soc_private_subnet_cidrs" {
  description = "CIDR blocks for the private SOC subnets"
  type        = list(string)
}

variable "workplace_private_subnet_cidrs" {
  description = "CIDR blocks for the private workplace subnets"
  type        = list(string)
}

variable "cluster_name" {
  description = "EKS cluster name for subnet tagging"
  type        = string
}

variable "enable_vpc_flow_logs" {
  description = "Whether to create VPC Flow Logs resources"
  type        = bool
}

variable "flow_logs_retention_days" {
  description = "Retention period in days for VPC Flow Logs"
  type        = number
}

variable "single_nat_gateway" {
  description = "Whether to use a single NAT gateway shared by all private subnets"
  type        = bool
}
