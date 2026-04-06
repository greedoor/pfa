# Rapport De Verification

## Objet

Ce document compare le depot Terraform/Kubernetes avec le cahier des charges `Chaier_des_charges (2).pdf` et precise ce qui est maintenant couvert, ce qui a ete complete, et ce qui reste a valider en environnement AWS reel.

## Verdict Global

Le projet initial n'etait pas faux, mais il etait incomplet par rapport au rapport PFE. Il provisionnait surtout une base `VPC + EKS` sans traduire toute l'architecture SOC decrite dans les chapitres 4 a 6.

Apres les modifications realisees dans ce depot, le projet est maintenant **largement coherent avec le cahier des charges**, avec les limites suivantes:

- la validation Terraform n'a pas pu etre executee ici car le binaire `terraform` n'est pas installe dans l'environnement local
- le deploiement AWS reel et les tests fonctionnels des composants SOC n'ont pas pu etre lances depuis ce workspace
- les manifests Kubernetes constituent une base de reference deployable, mais les images Wazuh/Shuffle devront encore etre ajustees avec les secrets, certificats et parametres definitifs

## Verification Par Exigence

| Exigence du cahier des charges | Etat initial | Etat apres correction | Preuve dans le depot |
| --- | --- | --- | --- |
| VPC segmente en zone Workplace, zone SOC et zone d'exposition | Partiel | Conforme | `main.tf`, `modules/vpc/main.tf`, `terraform.tfvars` |
| Cluster Kubernetes Multi-AZ | Conforme partiel | Conforme | `modules/eks/main.tf` |
| Pool analyse et pool stockage distincts | Non conforme | Conforme | `modules/eks/main.tf`, `variables.tf` |
| VPC Flow Logs pour la couche reseau | Non conforme | Conforme | `modules/vpc/main.tf` |
| Wazuh Manager en `StatefulSet` | Non implemente | Conforme | `k8s/base/wazuh-manager.yaml` |
| Indexer / stockage persistant en `StatefulSet` | Non implemente | Conforme | `k8s/base/wazuh-indexer.yaml`, `k8s/base/storageclass-gp3.yaml` |
| Dashboard / SOAR en `Deployment` | Non implemente | Conforme | `k8s/base/dashboard-and-soar.yaml` |
| CTI / enrichissement de menaces | Non implemente | Conforme partiel | `k8s/base/cti-enricher.yaml` |
| Monitoring Prometheus / Grafana | Non implemente | Conforme | `k8s/base/observability.yaml` |
| Falco en `DaemonSet` | Non implemente | Conforme | `k8s/base/falco-daemonset.yaml` |
| Elasticite 3 -> 10 repliques | Non conforme | Conforme | `variables.tf`, `k8s/base/security-controls.yaml` |
| Protection et resilience (`PDB`, `NetworkPolicy`) | Non conforme | Conforme partiel | `k8s/base/security-controls.yaml` |
| Documentation d'alignement avec le rapport | Faible | Conforme | `README.md`, `k8s/README.md`, `VERIFICATION_REPORT.md` |

## Ecarts Corriges

### 1. Architecture reseau

Avant:

- seulement des subnets publics et prives generiques
- aucune zone Workplace dediee
- aucune telesmetrie reseau integree

Maintenant:

- subnets `management_public_subnet_cidrs`
- subnets `soc_private_subnet_cidrs`
- subnets `workplace_private_subnet_cidrs`
- VPC Flow Logs vers CloudWatch

### 2. Architecture EKS

Avant:

- un seul node group generique

Maintenant:

- un node group `analysis`
- un node group `storage`
- labels Kubernetes pour scheduler les charges
- taint sur le pool `storage`

### 3. Cartographie des composants SOC

Avant:

- le rapport parlait de Wazuh, SOAR, CTI, monitoring et Falco
- le depot ne contenait pas d'objets Kubernetes correspondant a cette architecture

Maintenant:

- `StatefulSet` pour `Wazuh Manager`
- `StatefulSet` pour `Wazuh Indexer`
- `Deployment` autoscalable pour `Wazuh Analysis`
- `Deployment` pour `Wazuh Dashboard`
- `CronJob` pour la synchronisation CTI
- `Deployment` pour `Shuffle`
- `Deployment` pour `Prometheus` et `Grafana`
- `DaemonSet` pour `Falco`

## Points Encore A Finaliser En Production

Les points suivants ne sont pas des erreurs du depot, mais des actions finales de mise en service:

1. Installer Terraform sur la machine et executer `terraform init`, `terraform plan`, puis `terraform apply`.
2. Verifier que le compte AWS Academy accepte les types d'instances choisis (`c5.large`, `t3.large`).
3. Fournir les secrets applicatifs, certificats TLS, mots de passe, et configurations internes Wazuh.
4. Ajouter les vraies integrations CTI, par exemple `MISP`, `OTX`, `VirusTotal`, selon les droits et les API keys.
5. Tester les cas d'usage du chapitre 6: brute force, ransomware, exfiltration, privilege escalation.

## Conclusion

Le projet est maintenant beaucoup plus proche du cahier des charges et peut servir de base serieuse pour le PFE. La version precedente couvrait surtout l'infrastructure AWS de base; la version actuelle couvre en plus la segmentation reseau, la topologie EKS attendue, les composants Kubernetes du SOC, l'elasticite, la resilience et la documentation de verification.
