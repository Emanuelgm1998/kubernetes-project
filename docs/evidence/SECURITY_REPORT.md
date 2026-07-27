# Security Report

## Controls verified

- **PASS** — SSO assumed-role deployment identity; permanent IAM user rejected by the deployment guard.
- **PASS** — EKS Secrets envelope encryption with a rotating customer-managed KMS key.
- **PASS** — Terraform state encrypted by a separate rotating KMS key, versioned and blocked from public access.
- **PASS** — TLS-only S3 bucket policy and native lockfile backend.
- **PASS** — Nodes use private subnets, no external IPs, encrypted gp3 volumes and IMDSv2-required launch template.
- **PASS** — EKS access entry grants the real SSO role; creator bootstrap permissions disabled.
- **PASS** — IRSA roles are separated for VPC CNI, EBS CSI, LBC and External Secrets.
- **PASS** — External Secrets policy is scoped to `kubernetes-platform/dev/*`; STS role assumption was verified.
- **PASS** — Control-plane API, audit, authenticator, controller-manager and scheduler logs are enabled.
- **PASS** — Demo container is non-root, drops all capabilities, uses read-only root filesystem and RuntimeDefault seccomp.
- **PASS** — Namespace Pod Security labels and default-deny NetworkPolicy are present.

## Findings and risks

| Severity | Finding | Recommendation |
|---|---|---|
| Medium | Operator uses the broad `AdministratorAccess` permission set | Create a least-privilege deployment permission set |
| Medium | EKS public endpoint is enabled | Keep `/32` restriction current; prefer VPN/bastion/private administration |
| Medium | Internal ALB uses HTTP only | Add ACM certificate and HTTPS listener for any non-lab use |
| Medium | Private Git repository is not configured in Argo CD | Use a read-only GitHub App or deploy key delivered through a secret manager |
| Low | One NAT Gateway and one node per workload class | Increase per-AZ redundancy for production |
| Low | Control-plane logs retain only 7 days | Increase retention or archive for production compliance |
| Low | Ephemeral AWS CLI test pods generated PodSecurity warnings | Use a purpose-built non-root diagnostic image for future tests |
| Informational | Argo CD initial admin secret remains managed by the chart | Rotate/delete after establishing approved SSO/admin access |

## Secrets validation

Status: **NOT APPLICABLE / NO SECRET DEFINED**. The negative `DescribeSecret` test returned `ResourceNotFoundException`, demonstrating the request reached Secrets Manager under IRSA without claiming a real value read.

Future test procedure:

1. Create an approved secret named under `kubernetes-platform/dev/` without logging its value.
2. Define a namespaced SecretStore using the `external-secrets` ServiceAccount.
3. Define an ExternalSecret mapping that secret into a disposable Kubernetes Secret.
4. Validate `SecretStore Ready=True`, `ExternalSecret Ready=True`, secret key presence and checksum only.
5. Remove the test fixture only after separate cleanup authorization.
