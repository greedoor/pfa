# Wazuh Only Deployment

This folder deploys only the Wazuh part of the project, using the lighter AWS Academy-friendly setup.

## Included

- `wazuh-manager`
- `wazuh-indexer`
- `wazuh-analysis`
- `wazuh-dashboard`
- supporting services, quota, storage class, network policies, PDB, and HPA

## Excluded

- `shuffle`
- `prometheus`
- `grafana`
- `falco`
- `threat-intel-sync`
- shared ingress

## Deploy

```bash
kubectl apply -k k8s/wazuh-only
```

## Check

```bash
kubectl get all -n soc
kubectl get pods -n soc
kubectl get svc -n soc
```

## Open Wazuh Dashboard

```bash
kubectl port-forward svc/wazuh-dashboard 5601:5601 -n soc
```

Then open:

```text
http://localhost:5601
```
