# Deployment Guide

This runbook is for a future authorized AWS validation. Local hardening does not execute these deployment steps.

## Preconditions

- Use an authorized IAM Identity Center/SSO role; do not create permanent CI access keys.
- Confirm the target account and region with `aws sts get-caller-identity`.
- Verify EKS and add-on version support in the target region.
- Create and approve a dated cost estimate and cleanup window.
- For public API access, use only trusted operator `/32` CIDRs.
- Set `external_secrets_resource_arns` to an account-specific application prefix.

## Configure the environment

```bash
cp terraform/environments/dev/terraform.tfvars.example \
  terraform/environments/dev/terraform.tfvars
```

Review the new local file. It is ignored by Git.

## Initialize, validate and save the plan

```bash
./scripts/00-verify-tools.sh
./scripts/06-validate-local.sh
./scripts/01-terraform-init-plan.sh
terraform -chdir=terraform/environments/dev show tfplan
```

The plan file may contain sensitive values and must not be uploaded or attached to tickets without sanitization.

## Apply only the reviewed plan

After explicit approval:

```bash
./scripts/02-terraform-apply.sh
./scripts/03-update-kubeconfig.sh
```

Validate add-ons and nodes before bootstrapping workloads:

```bash
kubectl get nodes -o wide
aws eks describe-addon-versions --kubernetes-version <VERSION>
```

## Bootstrap platform services

```bash
./scripts/04-bootstrap-platform.sh
kubectl get pods -A
kubectl get applications -n argocd
```

The bootstrap reads Terraform outputs for VPC and IRSA identifiers. It does not write those values into Git.

## Acceptance checks

- EKS endpoint matches the intended private/public posture.
- Nodes have no public IP and span two AZs.
- Control-plane logs reach CloudWatch.
- Controllers use their intended service accounts and IAM roles.
- EBS CSI add-on is healthy.
- ArgoCD applications are synchronized and healthy.
- HPA reports CPU metrics.
- Ingress is internal unless a separately reviewed public TLS overlay is active.

Record evidence using the checklist in `validation-guide.md` and proceed to destruction within the approved cost window.
