# AWS Academy Setup for the SOC EKS Project

This project now ships with AWS Academy-friendly defaults in [terraform.tfvars](c:/Users/User/Downloads/soc1/soc1/soc/terraform.tfvars). It avoids the most common lab blockers:

- no OIDC provider creation
- no VPC Flow Logs IAM role creation
- smaller node sizes
- a single NAT gateway
- a lightweight Kubernetes overlay for demos

## 1. Open the AWS Academy Console

1. Open the lab dashboard.
2. Open the AWS Console from the lab panel.
3. Copy your temporary credentials if you need to configure the AWS CLI locally.

## 2. Find the Lab Role ARN

In the AWS Console:

1. Open `IAM` -> `Roles`
2. Search for:
   - `LabRole`
   - `voclabs`
   - any role pre-created by your instructor or lab template
3. Open the role and copy its ARN

In many AWS Academy labs, the same ARN can be used for both `cluster_role_arn` and `node_role_arn`.

## 3. Update terraform.tfvars

Replace the example values with your own:

```hcl
cluster_role_arn               = "arn:aws:iam::YOUR_ACCOUNT_ID:role/YOUR_LAB_ROLE"
node_role_arn                  = "arn:aws:iam::YOUR_ACCOUNT_ID:role/YOUR_LAB_ROLE"
create_oidc_provider           = false
```

## 4. Variables You Will Usually Keep

The defaults are already adapted for AWS Academy:

```hcl
management_public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
soc_private_subnet_cidrs       = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
workplace_private_subnet_cidrs = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
desired_worker_nodes           = 2
desired_storage_nodes          = 1
worker_instance_type           = "t3.medium"
storage_instance_type          = "t3.medium"
enable_vpc_flow_logs           = false
single_nat_gateway             = true
```

## 5. Run Terraform

Once the role ARNs are updated:

```bash
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

## 6. Configure kubectl

After apply succeeds:

```bash
aws eks update-kubeconfig --region us-east-1 --name soc-eks-cluster
kubectl get nodes
kubectl apply -k k8s/aws-academy
```

## Notes

- If `terraform plan` fails on IAM creation, confirm that `enable_vpc_flow_logs = false` and `create_oidc_provider = false`.
- If your lab forbids certain EC2 instance types, keep both node groups on `t3.medium`.
- If Terraform is not installed in your lab machine, install it before validation and deployment.
