# Validation Report

All statuses use only `PASS`, `PARTIAL`, `NOT APPLICABLE`, or `FAIL`.

| Component | Estado | Evidencia | Limitación | Resultado |
|---|---|---|---|---|
| AWS identity | PASS | STS account `747747309806`; assumed `AWSReservedSSO_AdministratorAccess_*` | AdministratorAccess is broad | Correct SSO identity |
| AWS region | PASS | CLI configuration and resources in `us-east-1` | None | Correct region |
| Terraform backend | PASS | Backend apply 8/0/0; encrypted/versioned S3 | Backend intentionally retained | Operational |
| Terraform final plan | PASS | JSON `0 add, 0 change, 0 destroy, 0 replace` | None | No drift |
| VPC | PASS | `vpc-0afaa326bd5f01d3b`, state available | Single lab VPC | Operational |
| VPC DNS | PASS | `enableDnsSupport=True`, `enableDnsHostnames=True` | None | Operational |
| Internet Gateway | PASS | `igw-0835a25651e8bbf84`, attached/available | None | Operational |
| NAT Gateway | PASS | `nat-01427916eff201083`, available | Single-AZ egress | Operational |
| Elastic IP | PASS | `eipalloc-0a5b968acee2bf0b1`, attached to NAT | Hourly IPv4 charge | Operational |
| Public subnets | PASS | Two CIDRs across 1a/1b; active IGW route | Public IP auto-assignment disabled | Operational |
| Private subnets | PASS | Two `/22` CIDRs across 1a/1b; NAT routes active | Shared NAT | Operational |
| Route tables | PASS | Three managed tables; all routes active | Default VPC table also exists | Operational |
| Security groups | PASS | EKS cluster SG and default SG inventoried | Rules should be periodically reviewed | Operational |
| IAM roles | PASS | Six project roles inventoried | Broad SSO operator role | Operational |
| IAM policies | PASS | LBC and External Secrets policies attached once each | Policy versions not separately archived | Operational |
| OIDC provider | PASS | Provider ARN ending `67C4362...7CA9` | None | Operational |
| IRSA VPC CNI | PASS | Add-on role ARN and ACTIVE health | Trust inspected through Terraform | Operational |
| IRSA EBS CSI | PASS | Add-on role ARN and ACTIVE health | Trust inspected through Terraform | Operational |
| IRSA Load Balancer Controller | PASS | Annotated ServiceAccount and working ALB | No separate STS pod test for this role | Operational |
| IRSA External Secrets | PASS | Real STS call assumed expected role | Test pod emitted PodSecurity warnings | Operational |
| KMS backend | PASS | Enabled, rotation enabled, SSE-KMS bucket | Key retained with backend | Operational |
| KMS EKS Secrets | PASS | Enabled, rotation enabled, cluster encryption config | None | Operational |
| CloudWatch Log Group | PASS | 7-day group, multiple control-plane streams | Short dev retention | Operational |
| CloudWatch recent logs | PASS | 5 timestamps read from latest kube-apiserver stream | Messages intentionally excluded | Verified |
| ECR | PASS | Immutable, scan-on-push, AES256 | No application image pushed | Operational |
| EKS control plane | PASS | `ACTIVE`, version 1.35 | Public endpoint enabled for operator | Operational |
| Public endpoint | PASS | Enabled and restricted to `190.101.28.15/32` | CIDR must be updated if IP changes | Reachable |
| Private endpoint | PASS | Enabled in `describe-cluster` | None | Operational |
| System node group | PASS | `ACTIVE`, healthy, desired 1 | Single node | Operational |
| Application node group | PASS | `ACTIVE`, healthy, desired 1 | Limited 17-pod capacity | Operational |
| Kubernetes nodes | PASS | 2/2 Ready, no external IPs | No multi-node redundancy per role | Operational |
| VPC CNI | PASS | 2/2 daemon pods Running; add-on ACTIVE | Historical transient IP event retained | Operational |
| CoreDNS | PASS | 2/2 Running; DNS tests passed | Both replicas currently share app node | Operational |
| kube-proxy | PASS | 2/2 daemon pods Running | None | Operational |
| EBS CSI | PASS | Controllers 2/2 and node daemonset 2/2 | No PVC workload test | Operational |
| Metrics Server | PASS | 2/2 Running; top/HPA metrics available | Initial readiness warnings resolved | Operational |
| AWS LBC | PASS | 2/2 Running; ALB active | HTTP-only internal listener | Operational |
| External Secrets operator | PASS | Three deployments Running | No SecretStore instance | Operational |
| Argo CD platform | PASS | Seven pods Running; Helm deployed | Initial scheduling failure corrected | Operational |
| Argo CD metrics app | PASS | `Synced/Healthy`, operation succeeded | None | Operational |
| Argo CD demo app | PARTIAL | Workload healthy; Argo condition says authentication required | Private repo lacks approved read-only credential | Blocked by private repository |
| Demo Deployment | PASS | 2/2 available and pods Running | Applied from local checkout | Operational |
| Service/DNS | PASS | DNS resolved and Service HTTP 200 | None | Operational |
| Ingress/ALB | PASS | Address assigned; in-cluster HTTP 200 | Internal only, no TLS | Operational |
| Target Group | PASS | 2 total, 2 healthy targets on port 8080 | None | Operational |
| API Server test | PASS | Authenticated `/version` HTTP 200 | Public access tied to current `/32` | Operational |
| HPA | PASS | CPU `1%/60%`, current replicas 2 | No load-scaling test | Metrics available |
| Network policies | PASS | Default deny plus DNS and ALB rules applied | Policy semantics not penetration-tested | Enforced by VPC CNI |
| Real secret read | NOT APPLICABLE | No project secret or ExternalSecret defined | Requires later approved test fixture | No secret defined |
| GitHub Actions current status | PARTIAL | Workflow YAML parsed; historical evidence exists | `gh` absent and private API returned 404 | Not currently revalidated |
| Destruction | NOT APPLICABLE | No destroy command executed | Awaiting explicit authorization | Infrastructure retained |

Current aggregate: 26 pods Running/Ready, 2 nodes Ready, EKS ACTIVE, 2/2 ALB targets healthy, Terraform zero drift.
