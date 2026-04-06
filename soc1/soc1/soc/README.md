# SOC Infrastructure for a Resilient Kubernetes-Based SOC

This repository now aligns the Terraform project more closely with the requirements described in the provided PFE brief. It provisions the AWS foundation for a resilient SOC and includes Kubernetes manifests that map the core SOC components to the cluster.

## What This Repository Covers

- A segmented AWS VPC with:
  - `management` public subnets for NAT gateways and public entry points
  - `soc` private subnets for EKS worker nodes
  - `workplace` private subnets for monitored Linux, Windows, or AD workloads
- An Amazon EKS cluster spread across multiple availability zones
- Two specialized EKS node groups:
  - `analysis` for Wazuh processing and stateless SOC services
  - `storage` for stateful workloads such as the indexer
- VPC Flow Logs sent to CloudWatch for network telemetry
- Optional OIDC provider creation for IRSA
- Kubernetes manifests in `k8s/base/` for the SOC reference deployment
- A verification report in `VERIFICATION_REPORT.md` that compares the implementation against the PDF brief

## Directory Layout

```text
.
|-- main.tf
|-- variables.tf
|-- outputs.tf
|-- terraform.tfvars
|-- AWS_ACADEMY_SETUP.md
|-- VERIFICATION_REPORT.md
|-- modules/
|   |-- vpc/
|   `-- eks/
`-- k8s/
    `-- base/
```

## Architecture Summary

### AWS Network Zones

- `Management Public`
  - NAT gateways
  - ingress and dashboard exposure point
- `SOC Private`
  - EKS node groups
  - Wazuh manager, indexer, dashboard, Shuffle, Prometheus, Grafana, Falco
- `Workplace Private`
  - monitored EC2 instances and AD systems

### Kubernetes Mapping

- `Wazuh Indexer`: `StatefulSet`
- `Wazuh Manager`: `StatefulSet`
- `Wazuh Analysis`: `Deployment` plus `HPA` from 3 to 10 replicas
- `CTI Enrichment`: `CronJob` scaffold for MISP or OTX synchronization
- `Dashboard / SOAR`: `Deployment`
- `Falco`: `DaemonSet`
- `Prometheus / Grafana`: `Deployment`

## Terraform Variables

The main variables are pre-filled in `terraform.tfvars`:

- `management_public_subnet_cidrs`
- `soc_private_subnet_cidrs`
- `workplace_private_subnet_cidrs`
- `desired_worker_nodes`, `min_worker_nodes`, `max_worker_nodes`
- `desired_storage_nodes`, `min_storage_nodes`, `max_storage_nodes`
- `enable_vpc_flow_logs`
- `cluster_endpoint_public_access`
- `cluster_endpoint_private_access`

## AWS Academy Ready Defaults

The checked-in [terraform.tfvars](c:/Users/User/Downloads/soc1/soc1/soc/terraform.tfvars) is now tuned for AWS Academy:

- `t3.medium` nodes instead of larger instance types
- `2` analysis nodes and `1` storage node by default
- `single_nat_gateway = true` to reduce cost
- `enable_vpc_flow_logs = false` to avoid extra IAM requirements
- `create_oidc_provider = false` for restricted lab accounts

## Deploy the AWS Infrastructure

1. Install Terraform, AWS CLI, and kubectl.
2. Update `terraform.tfvars` with your IAM role ARNs if you are using AWS Academy.
3. Run:

```bash
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

4. Configure kubectl:

```bash
aws eks update-kubeconfig --region us-east-1 --name soc-eks-cluster
```

## Deploy the Kubernetes Layer

After the cluster is ready:

Use the AWS Academy overlay first:

```bash
kubectl apply -k k8s/aws-academy
```

The `aws-academy` overlay reduces replicas and replaces persistent Wazuh storage with lighter ephemeral storage so the project can be demonstrated in a constrained lab account. The `k8s/base` manifests remain the fuller reference topology.

## Outputs

Useful Terraform outputs:

- `management_public_subnet_ids`
- `soc_private_subnet_ids`
- `workplace_private_subnet_ids`
- `vpc_flow_log_group_name`
- `analysis_node_group_arn`
- `storage_node_group_arn`
- `cluster_endpoint`
- `configure_kubectl`

## Limits and Assumptions

- This repository does not include real application secrets or certificates.
- AWS account-level validation was not possible from this workspace.
- The Kubernetes manifests are designed as a deployable reference baseline, not a fully tuned production Wazuh platform.
- If your lab environment blocks IAM OIDC creation, keep `create_oidc_provider = false`.
- For AWS Academy, prefer `kubectl apply -k k8s/aws-academy` before trying `k8s/base`.
