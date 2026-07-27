# Architecture Report

## Deployed topology

```text
IAM Identity Center operator
        |
        +-- EKS Access Entry / Cluster Admin Policy
        |
Internet -- EKS public API (operator /32 only)
        |
VPC 10.40.0.0/16, us-east-1a + us-east-1b
  |-- Public subnets -- IGW -- NAT Gateway + EIP
  |-- Private subnets
       |-- EKS control-plane ENIs / private API
       |-- system node group (t3.medium, tainted)
       |    `-- Argo CD and EKS platform components
       |-- application node group (t3.medium)
            |-- External Secrets / LBC / Metrics Server
            `-- demo-app (2 replicas)
                  `-- ClusterIP Service
                       `-- internal ALB -> IP targets
```

## Supporting services

- S3/KMS remote Terraform state with native locking.
- EKS KMS envelope encryption for Kubernetes Secrets.
- OIDC provider and four separated IRSA workloads.
- ECR immutable/scanned repository.
- CloudWatch control-plane logging.
- Argo CD for GitOps; Metrics Server is fully reconciled, demo repo authentication remains partial.

## Availability posture

Subnets and ALB span two AZs, and application replicas are topology-aware. The laboratory is not production highly available because it uses one NAT Gateway and one node per managed node group. The system/app scheduling separation was validated by moving Argo CD to the tainted system node through explicit selector/toleration configuration.

## Production gap

This is a hardened portfolio/dev architecture, not a production platform. Production requires multi-AZ egress, multiple nodes per workload class, private operator access, TLS, GitOps repository credential rotation, real secret integration, stronger monitoring/alerting, backups and tested disaster recovery.
