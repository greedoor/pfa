# AWS Academy Overlay

This overlay is the version you should deploy first in AWS Academy.

## What it changes

- reduces `Wazuh Manager` to 1 replica
- replaces `Wazuh Indexer` and `Wazuh Manager` persistent storage with `emptyDir`
- reduces deployment replicas and resource requests
- lowers the `HPA` range to `1..2`
- keeps the same service names so the rest of the stack still connects

## Apply

```bash
kubectl apply -k k8s/aws-academy
```

## Why this exists

AWS Academy labs often block IAM features needed by the EBS CSI driver and usually have lower EC2 quota. This overlay is optimized to let you demonstrate the SOC architecture even in that constrained environment.
