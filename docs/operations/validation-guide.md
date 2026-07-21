# Validation Guide

## Local, no AWS credentials

Run:

```bash
./scripts/06-validate-local.sh
```

Expected checks:

- Terraform formatting and validation;
- Kustomize rendering for the platform and ArgoCD applications;
- ShellCheck and Yamllint when installed;
- Git whitespace validation.

No local validation proves that an AWS API accepts the configuration. Provider installation can require network access but not AWS credentials.

## Future AWS plan

Prerequisites:

1. Authorized AWS account and operator identity.
2. Dated AWS Pricing Calculator estimate.
3. Supported EKS and add-on versions verified in the target region.
4. Trusted operator network path or explicit `/32` API CIDR.
5. Reviewed Secrets Manager ARN boundary.

Create and inspect a saved plan:

```bash
./scripts/01-terraform-init-plan.sh
terraform -chdir=terraform/environments/dev show tfplan
```

Review resource count, IAM policies, public endpoints, deletion behavior, tags and projected costs before authorization to apply.

## Evidence checklist

- AWS caller identity and region, with account number redacted.
- Plan summary without sensitive values.
- Private/public subnet route tables.
- EKS endpoint access settings and control-plane logs.
- Node placement in private subnets.
- OIDC provider and IRSA service-account subjects.
- Healthy EBS CSI, VPC CNI, CoreDNS and kube-proxy add-ons.
- ArgoCD applications synchronized.
- HPA receiving Metrics Server data.
- Internal ALB and, if enabled, HTTPS/WAF association.
- Final destruction verification with zero orphaned ALBs, ENIs, NAT Gateways and volumes.
