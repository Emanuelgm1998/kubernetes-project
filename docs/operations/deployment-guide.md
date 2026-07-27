# Deployment Guide

This runbook is for a future authorized AWS validation. Local hardening does not execute these deployment steps.

## Preconditions

- Use an authorized IAM Identity Center/SSO role; do not create permanent CI access keys.
- Confirm the target account and region with `aws sts get-caller-identity`.
- Verify EKS and add-on version support in the target region.
- Create and approve a dated cost estimate and cleanup window.
- For public API access, use only trusted operator `/32` CIDRs.
- Confirm the generated External Secrets boundary matches `<project>/<environment>/*` in the target account.
- Select an IAM role ARN for `cluster_admin_principal_arn`; IAM user ARNs are rejected.

The audited account did not contain an Identity Center user, Permission Set, assignment or suitable role on 2026-07-21. Complete the [IAM Identity Center setup](identity-center-setup.md) first. Do not substitute the current IAM user ARN.

After provisioning the assignment, obtain the complete ARN directly from AWS:

```bash
export ADMIN_ROLE_ARN="$(
  aws iam list-roles \
    --query 'Roles[?starts_with(RoleName, `AWSReservedSSO_PlatformAdministrator_`)].Arn | [0]' \
    --output text
)"
```

Confirm the resolved value:

```bash
[ -n "$ADMIN_ROLE_ARN" ] && [ "$ADMIN_ROLE_ARN" != "None" ] || exit 1
printf '%s\n' "$ADMIN_ROLE_ARN"
aws iam get-role --role-name "${ADMIN_ROLE_ARN##*/}" --query 'Role.Arn' --output text
```

## Bootstrap remote state once

This is a separate, explicitly approved apply. It creates only the protected state foundation (S3 bucket and KMS key). Its local state is sensitive and must be backed up securely.

Verify the SSO identity before every plan or apply:

```bash
export AWS_PROFILE=kubernetes-project
export AWS_REGION=us-east-1
aws sso login --profile "$AWS_PROFILE"
./scripts/07-verify-deployment-identity.sh
```

```bash
terraform -chdir=terraform/bootstrap/state init
terraform -chdir=terraform/bootstrap/state fmt -check
terraform -chdir=terraform/bootstrap/state validate
terraform -chdir=terraform/bootstrap/state plan -out=tfplan
terraform -chdir=terraform/bootstrap/state show tfplan
# After explicit approval only:
terraform -chdir=terraform/bootstrap/state apply tfplan
```

Create the ignored backend configuration using the output:

```bash
cp terraform/environments/dev/backend.hcl.example terraform/environments/dev/backend.hcl
export STATE_BUCKET="$(terraform -chdir=terraform/bootstrap/state output -raw state_bucket_name)"
export STATE_KMS_KEY_ARN="$(terraform -chdir=terraform/bootstrap/state output -raw state_kms_key_arn)"

sed -i "s#REPLACE_WITH_TERRAFORM_STATE_BUCKET#$STATE_BUCKET#" \
  terraform/environments/dev/backend.hcl
sed -i "s#REPLACE_WITH_TERRAFORM_STATE_KMS_KEY_ARN#$STATE_KMS_KEY_ARN#" \
  terraform/environments/dev/backend.hcl
```

Confirm that `backend.hcl` is ignored and contains no placeholder.

## Configure the environment

```bash
cp terraform/environments/dev/terraform.tfvars.example \
  terraform/environments/dev/terraform.tfvars

sed -i \
  "s#arn:aws:iam::123456789012:role/AWSReservedSSO_PlatformAdministrator_REPLACE_ME#$ADMIN_ROLE_ARN#" \
  terraform/environments/dev/terraform.tfvars
```

Review the new local file. It is ignored by Git.

Set `cluster_admin_principal_arn` to an existing IAM role. If the API endpoint remains private, run the Kubernetes bootstrap from an approved network path into the VPC. For a short-lived workstation deployment without private connectivity, explicitly enable the public endpoint and restrict it to the operator's public `/32`.

Run the placeholder and ignore checks from the final section of [IAM Identity Center Setup](identity-center-setup.md) before planning.

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
- If WAF is enabled, its Web ACL ARN is associated with the public ALB; merely creating an ACL provides no protection.

Track execution in the [deployment checklist](deployment-checklist.md), record runtime results with the [evidence template](../evidence/deployment-template.md), and proceed to destruction only after explicit approval.
