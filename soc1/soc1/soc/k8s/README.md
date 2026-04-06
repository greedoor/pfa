# Kubernetes Layer

This folder contains a reference Kubernetes implementation of the SOC components described in the project brief.

## What is Included

- `StatefulSet` for `Wazuh Manager`
- `StatefulSet` for `Wazuh Indexer`
- `Deployment` for `Wazuh Analysis` with `HPA` from 3 to 10 replicas
- `Deployment` for `Wazuh Dashboard`
- `CronJob` for CTI synchronization scaffolding
- `Deployment` for `Shuffle`
- `Deployment` for `Prometheus`
- `Deployment` for `Grafana`
- `DaemonSet` for `Falco`
- `StorageClass` based on encrypted `gp3` EBS volumes
- `PodDisruptionBudget`, `NetworkPolicy`, and `Ingress` resources

## Apply

```bash
kubectl apply -k k8s/base
```

## Important Notes

- The manifests are a project-aligned baseline intended to match the architecture in the report.
- Production Wazuh deployments usually require vendor-specific tuning, certificates, credentials, and storage sizing adjustments.
- The node affinity model assumes the Terraform-managed EKS node groups expose the labels `workload=analysis` and `workload=storage`.
