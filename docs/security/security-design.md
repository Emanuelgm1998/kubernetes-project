# Security Design and Threat Model

## Trust boundaries

- Developer workstation to GitHub.
- GitHub Actions to repository contents; CI has no AWS credentials.
- Terraform operator identity to AWS APIs.
- EKS control plane to private worker nodes.
- Kubernetes service accounts to AWS STS through IRSA.
- ALB to application pods.
- ArgoCD to the Git repository and Kubernetes API.

## Identity

Operators should use IAM Identity Center/SSO. Future GitHub deployment automation must use GitHub OIDC with repository, branch/environment and audience conditions; permanent access keys are prohibited.

IRSA roles bind both `sub` and `aud` claims. External Secrets is restricted to configured Secrets Manager ARNs. EBS CSI uses the AWS-managed driver policy. The Load Balancer Controller policy uses controller ownership tags to constrain mutating operations.

## Network controls

- Nodes are private.
- EKS private endpoint is always enabled; public endpoint is disabled by default.
- Public endpoint configuration rejects `0.0.0.0/0`.
- VPC CNI NetworkPolicy support is enabled.
- Application namespaces use default-deny ingress and egress.
- Demo ingress is internal by default.

A public workload requires HTTPS, an ACM certificate, DNS, WAF association, explicit source requirements and a reviewed NetworkPolicy overlay.

## Workload controls

- Restricted Pod Security Admission for the apps namespace.
- Non-root UID/GID, RuntimeDefault seccomp and all capabilities dropped.
- Read-only root filesystem with explicit ephemeral writable mounts.
- Service-account token automount disabled.
- CPU/memory requests and limits, probes, PDB and topology spreading.

The demo image is versioned but not yet pinned by digest. A future release process must build into ECR, scan the image, generate an SBOM, sign it and promote an immutable digest.

## Secrets

No credential values belong in Terraform, YAML, scripts, documentation, plan artifacts or GitHub workflows. Local `terraform.tfvars`, Terraform state, saved plans, kubeconfigs and `.env` files are ignored. Terraform plan/state must still be stored and transmitted as sensitive artifacts.

Grafana is disabled by default. If enabled, its administrator secret must come from a Kubernetes Secret populated through an approved secret-management flow.

## Threats and mitigations

| Threat | Current mitigation | Remaining work |
|---|---|---|
| Stolen static cloud key | No CI keys; SSO guidance | Configure GitHub OIDC before deployment automation |
| Exposed Kubernetes API | Private by default; `/0` rejected | Private operator connectivity |
| Pod obtains broad AWS access | Per-controller IRSA | Split VPC CNI permission from node bootstrap |
| Malicious image/tag replacement | ECR immutable tags | Digest pinning, signature verification and SBOM |
| Internet attack on workload | Internal ALB, NetworkPolicy | Public TLS/WAF overlay and runtime evidence |
| GitOps privilege escalation | Restricted AppProject | Separate platform/application projects for larger environments |
| Secret committed to Git | Ignore rules and Gitleaks CI | Repository protection and rotation runbook |
| Orphaned billable resources | Ordered destroy runbook | Automated inventory/evidence in a real account |

## Logging and response

All EKS control-plane log types are enabled with seven-day retention for dev. A production design needs centralized immutable retention, alerting, CloudTrail integration and a documented incident-response owner. No claim of operational detection coverage is made until validated in AWS.
