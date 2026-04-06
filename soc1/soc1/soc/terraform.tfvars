aws_region                     = "us-east-1"
environment                    = "dev"
project_name                   = "soc"
vpc_name                       = "soc_vpc"
vpc_cidr                       = "10.0.0.0/16"
management_public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
soc_private_subnet_cidrs       = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
workplace_private_subnet_cidrs = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
cluster_name                   = "soc-eks-cluster"
kubernetes_version             = "1.29"
desired_worker_nodes           = 2
min_worker_nodes               = 2
max_worker_nodes               = 4
worker_instance_type           = "t3.medium"
worker_disk_size               = 30
desired_storage_nodes          = 1
min_storage_nodes              = 1
max_storage_nodes              = 2
storage_instance_type          = "t3.medium"
storage_disk_size              = 50
cluster_endpoint_public_access = true
cluster_endpoint_private_access = true
enable_vpc_flow_logs           = false
flow_logs_retention_days       = 30
single_nat_gateway             = true

# AWS Academy Labs: add your IAM role ARNs below.
# Leave empty ("") to create new roles if your account allows IAM creation.
# See AWS_ACADEMY_SETUP.md for guidance.
cluster_role_arn               = "arn:aws:iam::366298399297:role/LabRole"
node_role_arn                  = "arn:aws:iam::366298399297:role/LabRole"

# AWS Academy Labs: set to false to skip OIDC provider creation when the lab denies IAM OIDC actions.
create_oidc_provider           = false
