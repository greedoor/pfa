terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}

module "vpc" {
  source = "./modules/vpc"

  vpc_name                       = var.vpc_name
  vpc_cidr                       = var.vpc_cidr
  management_public_subnet_cidrs = var.management_public_subnet_cidrs
  soc_private_subnet_cidrs       = var.soc_private_subnet_cidrs
  workplace_private_subnet_cidrs = var.workplace_private_subnet_cidrs
  cluster_name                   = var.cluster_name
  enable_vpc_flow_logs           = var.enable_vpc_flow_logs
  flow_logs_retention_days       = var.flow_logs_retention_days
  single_nat_gateway             = var.single_nat_gateway
}

module "eks" {
  source = "./modules/eks"

  cluster_name            = var.cluster_name
  kubernetes_version      = var.kubernetes_version
  management_subnet_ids   = module.vpc.management_public_subnet_ids
  soc_subnet_ids          = module.vpc.soc_private_subnet_ids
  security_group_id       = module.vpc.security_group_id
  analysis_desired_nodes  = var.desired_worker_nodes
  analysis_min_nodes      = var.min_worker_nodes
  analysis_max_nodes      = var.max_worker_nodes
  analysis_instance_types = [var.worker_instance_type]
  analysis_disk_size      = var.worker_disk_size
  storage_desired_nodes   = var.desired_storage_nodes
  storage_min_nodes       = var.min_storage_nodes
  storage_max_nodes       = var.max_storage_nodes
  storage_instance_types  = [var.storage_instance_type]
  storage_disk_size       = var.storage_disk_size
  cluster_role_arn        = var.cluster_role_arn
  node_role_arn           = var.node_role_arn
  create_oidc_provider    = var.create_oidc_provider
  endpoint_public_access  = var.cluster_endpoint_public_access
  endpoint_private_access = var.cluster_endpoint_private_access
}
