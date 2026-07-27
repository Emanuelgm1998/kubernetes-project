# AWS Live Deployment Evidence

> Do not record credentials, access keys, tokens, kubeconfig contents, Terraform state or unredacted sensitive outputs.

## Deployment metadata

| Field | Evidence |
|---|---|
| Date | `YYYY-MM-DD` |
| Start time | `HH:MM TZ` |
| Commit | `<git rev-parse HEAD>` |
| Account | `<redacted account reference>` |
| Region | `us-east-1` |
| Operator role | `<AWSReservedSSO role name>` |
| Planned destruction time | `YYYY-MM-DD HH:MM TZ` |
| Actual destruction time | `<pending>` |

## Terraform

- Backend plan summary: `<add/change/destroy>`
- EKS plan summary: `<add/change/destroy>`
- Remote state encryption: `<KMS key alias; do not include sensitive policy output>`
- Apply result: `<success/failure and timestamp>`

## Nodes

```text
<sanitized kubectl get nodes -o wide output>
```

## Add-ons

| Add-on | Version | Status | Service-account role |
|---|---|---|---|
| vpc-cni | `<version>` | `<status>` | `<role name>` |
| coredns | `<version>` | `<status>` | N/A |
| kube-proxy | `<version>` | `<status>` | N/A |
| aws-ebs-csi-driver | `<version>` | `<status>` | `<role name>` |

## IRSA

| Component | Namespace | Service account | Role | Validation |
|---|---|---|---|---|
| VPC CNI | kube-system | aws-node | `<role>` | `<evidence>` |
| EBS CSI | kube-system | ebs-csi-controller-sa | `<role>` | `<evidence>` |
| AWS Load Balancer Controller | kube-system | aws-load-balancer-controller | `<role>` | `<evidence>` |
| External Secrets | external-secrets | external-secrets | `<role>` | `<evidence>` |

## ArgoCD

- Version: `<version>`
- Application revision: `<commit>`
- Sync status: `<Synced>`
- Health status: `<Healthy>`

```text
<sanitized kubectl get applications -n argocd output>
```

## ALB end-to-end

- Scheme: `<internal/internet-facing>`
- State: `<active>`
- Target health: `<healthy>`
- HTTP result: `<200>`

```text
<sanitized ALB target-health and HTTP response evidence>
```

## Cost evidence

- Estimate date: `YYYY-MM-DD`
- Estimated monthly run rate: `<amount and currency>`
- Actual test duration: `<hours>`
- Main cost drivers: `<EKS, EC2, NAT, ALB, KMS, CloudWatch>`

## Destruction evidence

- Authorized by: `<name/reference>`
- Terraform destroy result: `<pending>`
- ALBs/target groups removed: `<pending>`
- NAT Gateway and EIPs removed: `<pending>`
- EKS/node groups removed: `<pending>`
- Orphan inventory result: `<pending>`
- Backend retention decision: `<retained/destroy separately>`
