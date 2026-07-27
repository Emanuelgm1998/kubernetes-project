<p align="center">
  <img src="docs/images/project-banner.svg" alt="AWS EKS Kubernetes Platform banner" width="100%">
</p>

<p align="center">
  <strong>A security-focused, multi-AZ Kubernetes platform on Amazon EKS, built with modular Terraform and validated with real runtime evidence.</strong>
</p>

<p align="center">
  <a href="terraform/environments/dev/provider.tf"><img src="https://img.shields.io/badge/Terraform-1.15-844FBA?logo=terraform&logoColor=white" alt="Terraform 1.15"></a>
  <a href="https://aws.amazon.com/eks/"><img src="https://img.shields.io/badge/AWS-Amazon_EKS-FF9900?logo=amazonaws&logoColor=white" alt="AWS Amazon EKS"></a>
  <a href="kubernetes/"><img src="https://img.shields.io/badge/Kubernetes-1.35-326CE5?logo=kubernetes&logoColor=white" alt="Kubernetes 1.35"></a>
  <a href=".github/workflows/terraform-ci.yml"><img src="https://github.com/Emanuelgm1998/kubernetes-project/actions/workflows/terraform-ci.yml/badge.svg" alt="Terraform CI"></a>
  <a href=".github/workflows/security-ci.yml"><img src="https://img.shields.io/badge/DevSecOps-Trivy_%7C_Gitleaks-0F766E?logo=securityscorecard&logoColor=white" alt="DevSecOps"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-green.svg" alt="MIT License"></a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Linux-Amazon_Linux_2023-FCC624?logo=linux&logoColor=111827" alt="Linux">
  <img src="https://img.shields.io/badge/IaC-Terraform-7B42BC?logo=terraform&logoColor=white" alt="Infrastructure as Code">
  <img src="https://img.shields.io/badge/Cloud_Security-KMS_%7C_IRSA_%7C_IMDSv2-DC2626" alt="Cloud Security">
  <img src="https://img.shields.io/badge/Zero_Trust-Identity--Aware-0EA5E9" alt="Zero Trust">
  <img src="https://img.shields.io/badge/Runtime_Status-94%25_Verified-16A34A" alt="94 percent verified">
</p>

---

## Overview

This repository is a portfolio-grade implementation of a short-lived AWS Kubernetes platform. It demonstrates the work expected from a Cloud, DevOps or Platform Engineer: remote state bootstrap, network design, EKS lifecycle, workload identity, GitOps, controller installation, security hardening, functional testing, cost control and auditable evidence.

The environment was deployed in `us-east-1` and verified on 2026-07-27. Terraform converged with **0 add / 0 change / 0 destroy / 0 replace** after deployment. Amazon EKS 1.35, both managed node groups, the four EKS add-ons, the internal ALB and all observed Kubernetes workloads reached healthy runtime states. The infrastructure remains active pending explicitly authorized destruction.

> [!IMPORTANT]
> This is a hardened **portfolio/dev laboratory**, not a claim of production readiness. The verified completion level is **94%**: demo GitOps reconciliation is blocked by private-repository authentication, and a real secret read is not applicable because the project defines no AWS Secrets Manager test secret.

## Deployment Successfully Validated

> [!TIP]
> The platform was deployed on AWS and validated from infrastructure provisioning through live Kubernetes runtime checks. Every claim below maps to the version-controlled evidence package.

| Validated outcome | Status | Verification source |
|---|:---:|---|
| Amazon EKS cluster Active | ✅ | [AWS deployment evidence](docs/evidence/DEPLOYMENT_EVIDENCE.md#aws-evidence) |
| Kubernetes v1.35 | ✅ | [Kubernetes evidence](docs/evidence/DEPLOYMENT_EVIDENCE.md#kubernetes-evidence) |
| 2 managed nodes Ready | ✅ | [Runtime screenshot](docs/images/kubernetes-nodes-ready.png) |
| Argo CD platform Running | ✅ | [Validation matrix](docs/evidence/VALIDATION_REPORT.md) |
| External Secrets operator Running | ✅ | [Validation matrix](docs/evidence/VALIDATION_REPORT.md) |
| Metrics Server Running and serving metrics | ✅ | [Validation matrix](docs/evidence/VALIDATION_REPORT.md) |
| AWS Load Balancer Controller Running | ✅ | [Functional evidence](docs/evidence/DEPLOYMENT_EVIDENCE.md#functional-evidence) |
| Terraform apply successful and converged | ✅ | [Terraform evidence](docs/evidence/DEPLOYMENT_EVIDENCE.md#terraform-evidence) |
| Runtime validation completed | ✅ | [Project completion report](docs/evidence/PROJECT_COMPLETION_REPORT.md) |

The Argo CD platform itself is healthy. Demo-application Git reconciliation remains **PARTIAL** because the private repository has no approved read-only Argo CD credential; the workload was validated from reviewed local manifests. No real secret-read success is claimed because no test secret exists.

## Architecture

```mermaid
flowchart TB
    Operator["Operator · IAM Identity Center"] -->|"AWSReservedSSO role"| Access["EKS Access Entry"]
    GitHub["GitHub Repository"] --> CI["GitHub Actions\nTerraform · Platform · Security"]
    Terraform["Terraform"] --> State["S3 Remote State\nVersioning · Native Lock · SSE-KMS"]
    Terraform --> AWS

    subgraph AWS["AWS Account · us-east-1"]
      direction TB
      KMS["Customer-managed KMS\nState + EKS Secrets"]
      ECR["Amazon ECR\nImmutable · Scan on Push"]
      CW["CloudWatch\nAPI · Audit · Authenticator · Scheduler"]

      subgraph VPC["VPC 10.40.0.0/16 · Two Availability Zones"]
        direction LR
        subgraph Public["Public Subnets · 1a / 1b"]
          IGW["Internet Gateway"]
          NAT["Shared NAT Gateway"]
        end
        subgraph Private["Private Subnets · 1a / 1b"]
          EKS["Amazon EKS 1.35\nPrivate + restricted public API"]
          System["System Node Group\nt3.medium · tainted"]
          Apps["Application Node Group\nt3.medium"]
        end
        ALB["Internal Application Load Balancer\n2/2 healthy IP targets"]
      end
    end

    Access --> EKS
    EKS --> System
    EKS --> Apps
    EKS --> CW
    KMS --> State
    KMS --> EKS
    ECR --> Apps
    Private --> NAT --> IGW
    System --> Argo["Argo CD"]
    Apps --> LBC["AWS Load Balancer Controller"]
    Apps --> ESO["External Secrets"]
    Apps --> Metrics["Metrics Server"]
    Apps --> Demo["Demo App · 2 replicas"]
    LBC --> ALB --> Demo
    GitHub -. "private repo: credential pending" .-> Argo
```

The design separates system and application capacity, keeps worker nodes private, enables both private API access and a public endpoint restricted to the operator's observed `/32`, and uses an internal ALB for the demo workload. See the [architecture report](docs/evidence/ARCHITECTURE_REPORT.md) for the deployed topology and production gaps.

## Technology stack

| Layer | Technology | Verified implementation |
|---|---|---|
| Cloud | AWS, Amazon EKS 1.35 | Active control plane in `us-east-1` |
| Infrastructure as Code | Terraform 1.15, AWS provider 5.100 | Modular stacks, remote backend, zero drift |
| Networking | VPC, 4 subnets, IGW, NAT Gateway, ALB | Two AZs, private nodes, active routes |
| Compute | EKS managed node groups, Amazon Linux 2023 | 2 × `t3.medium`, both Ready |
| Identity | IAM Identity Center, IAM, EKS Access Entry | SSO role validated; implicit creator admin disabled |
| Workload identity | OIDC, IRSA | VPC CNI, EBS CSI, LBC and External Secrets roles |
| Encryption | AWS KMS, S3 SSE-KMS, encrypted gp3 | Separate rotating keys for state and EKS Secrets |
| Containers | Kubernetes, Kustomize, Helm | 26/26 observed pods Running/Ready |
| GitOps | Argo CD 3.4.5 | Platform healthy; Metrics Server Synced/Healthy |
| Platform services | AWS LBC, External Secrets, Metrics Server, EBS CSI | Deployed and runtime-validated |
| Observability | CloudWatch control-plane logs, Metrics API | Recent streams/events and live resource metrics |
| CI/CD security | GitHub Actions, Trivy, Gitleaks | Terraform, manifest and security workflows |
| Operating system | Linux, Amazon Linux 2023 | IMDSv2-required private worker nodes |

## AWS architecture

- **VPC and routing:** one `10.40.0.0/16` VPC across `us-east-1a` and `us-east-1b`, with two public `/24` subnets, two private `/22` subnets, an Internet Gateway and a shared NAT Gateway.
- **Amazon EKS:** Kubernetes 1.35 with API, audit, authenticator, controller-manager and scheduler logging. Secrets use KMS envelope encryption.
- **Managed node groups:** dedicated system and application groups using on-demand `t3.medium` instances, encrypted 30 GiB gp3 volumes, IMDSv2 and no public IPs.
- **IAM, OIDC and IRSA:** an explicit EKS Access Entry for the SSO role and independent workload roles bound to exact Kubernetes ServiceAccounts.
- **Ingress:** AWS Load Balancer Controller provisions an internal ALB. Its target group was verified with 2/2 healthy pod IP targets.
- **Platform services:** EBS CSI, VPC CNI, CoreDNS and kube-proxy are EKS add-ons; Argo CD, External Secrets and Metrics Server are deployed through Helm/GitOps workflows.
- **Terraform backend:** protected S3 state with versioning, public-access blocking, TLS enforcement, native lockfile support and a customer-managed KMS key.
- **Registry and observability:** ECR uses immutable tags and scan-on-push; CloudWatch retains EKS control-plane logs for seven days in the dev profile.

## Project Highlights

- **Full platform lifecycle:** remote-state bootstrap, reviewed Terraform plan, controlled apply, Kubernetes bootstrap, runtime validation and zero-drift confirmation.
- **Real AWS runtime:** EKS 1.35, two managed node groups, four managed add-ons, private workers and an internal ALB with 2/2 healthy targets.
- **Security by design:** IAM Identity Center, EKS Access Entries, KMS encryption, IRSA, IMDSv2, restricted API ingress and hardened pod security contexts.
- **Platform engineering:** Argo CD, AWS Load Balancer Controller, External Secrets and Metrics Server integrated into a modular cluster foundation.
- **Functional proof:** DNS, ClusterIP Service, authenticated Kubernetes API and ALB paths returned HTTP 200; live CPU and memory metrics were retrieved.
- **Auditable delivery:** seven professional reports capture resource inventory, validation results, security posture, costs, architecture and command history.
- **Operational discipline:** identity guards, saved plans, approval gates and a controlled destruction runbook protect the environment lifecycle.

## Enterprise Features

| Capability | Implementation | Verified value |
|---|---|---|
| **IRSA** | Dedicated roles for VPC CNI, EBS CSI, AWS LBC and External Secrets | Pod-level AWS identity without distributing static credentials; External Secrets STS assumption validated |
| **OIDC federation** | EKS OIDC provider with ServiceAccount-bound trust policies | Identity is scoped to exact Kubernetes subjects |
| **Least-privilege IAM** | Separate workload roles and scoped secret path | Reduces workload blast radius; broad lab operator access remains documented as a risk |
| **GitOps** | Argo CD platform and restricted AppProject | Metrics application reconciled Synced/Healthy; private demo repository authentication remains pending |
| **Multi-AZ design** | Public/private subnets and ALB across two Availability Zones | AZ-aware network foundation; one node per group and one NAT Gateway remain lab constraints |
| **Terraform remote state** | Versioned S3, SSE-KMS, public-access block, TLS-only policy and native locking | Encrypted, durable and concurrency-aware state management |
| **CloudWatch observability** | All EKS control-plane log types enabled with seven-day lab retention | Recent API server events and multiple control-plane streams verified |
| **Modular architecture** | Independent VPC, EKS, ECR, IRSA and security modules | Reviewable components with explicit environment composition |

## Deployment workflow

```mermaid
flowchart LR
    A["SSO identity preflight"] --> B["Bootstrap S3/KMS state"]
    B --> C["Configure ignored backend.hcl + tfvars"]
    C --> D["terraform init + validate"]
    D --> E["Saved terraform plan"]
    E --> F{"Manual approval"}
    F -->|Approved| G["terraform apply tfplan"]
    G --> H["Update kubeconfig"]
    H --> I["Bootstrap controllers + Argo CD"]
    I --> J["AWS + Kubernetes validation"]
    J --> K["Evidence package"]
    K --> L{"Separate destroy approval"}
```

Every apply is preceded by identity validation and review of a saved plan. Terraform state and plan files are never committed.

## Runtime Evidence

### Amazon EKS cluster — Active

<p align="center">
  <img src="docs/images/eks-cluster-active.png" alt="Amazon EKS cluster kubernetes-platform-dev in Active state" width="92%">
</p>

This AWS Console capture proves that the deployed `kubernetes-platform-dev` control plane reached the **Active** lifecycle state. It complements the AWS CLI evidence for Kubernetes 1.35 and the configured public/private endpoints.

### Kubernetes nodes — 2/2 Ready

<p align="center">
  <img src="docs/images/kubernetes-nodes-ready.png" alt="kubectl get nodes showing two Ready private EKS nodes" width="92%">
</p>

This terminal capture proves that both managed EC2 worker nodes joined the cluster and reported **Ready**. The wide output also supports the validation that the nodes use private addressing with no external IPs.

### Kubernetes workloads — Running

<p align="center">
  <img src="docs/images/kubernetes-pods-running.png" alt="kubectl get pods across all namespaces showing Running workloads" width="92%">
</p>

This cluster-wide pod inventory proves the observed runtime state of the EKS add-ons and platform services, including Argo CD, External Secrets, Metrics Server and AWS Load Balancer Controller. At evidence time, all 26 observed pods were Running/Ready.

## Deployment summary

| Validation | Result | Evidence |
|---|---|---|
| Terraform convergence | **PASS** — 0 add, 0 change, 0 destroy, 0 replace | [Validation report](docs/evidence/VALIDATION_REPORT.md) |
| Amazon EKS | **PASS** — Active, Kubernetes 1.35 | [Deployment evidence](docs/evidence/DEPLOYMENT_EVIDENCE.md) |
| Managed nodes | **PASS** — 2/2 Ready, no external IPs | [Screenshot](docs/images/kubernetes-nodes-ready.png) |
| Kubernetes workloads | **PASS** — 26/26 observed pods Running/Ready | [Screenshot](docs/images/kubernetes-pods-running.png) |
| EKS add-ons | **PASS** — VPC CNI, CoreDNS, kube-proxy, EBS CSI Active | [Validation report](docs/evidence/VALIDATION_REPORT.md) |
| Internal ALB | **PASS** — active, HTTP 200, 2/2 targets healthy | [Deployment evidence](docs/evidence/DEPLOYMENT_EVIDENCE.md) |
| CloudWatch | **PASS** — control-plane streams and recent events verified | [Validation report](docs/evidence/VALIDATION_REPORT.md) |
| IRSA | **PASS** — real STS assumption through External Secrets ServiceAccount | [Security report](docs/evidence/SECURITY_REPORT.md) |
| Metrics Server | **PASS** — Synced/Healthy; `kubectl top` and HPA operational | [Validation report](docs/evidence/VALIDATION_REPORT.md) |
| External Secrets operator | **PASS** — three deployments Running | [Validation report](docs/evidence/VALIDATION_REPORT.md) |
| Demo GitOps | **PARTIAL** — workload healthy; private Git repository credential pending | [Completion report](docs/evidence/PROJECT_COMPLETION_REPORT.md) |
| Real secret value read | **NOT APPLICABLE** — no test secret defined | [Security report](docs/evidence/SECURITY_REPORT.md) |

## Why this project matters

This repository demonstrates more than the ability to provision an EKS cluster. It shows the engineering judgment required to design, secure, operate and audit a cloud-native platform across its full lifecycle.

For Cloud, DevOps, Platform Engineering and Cloud Security roles, the project provides concrete evidence of:

- translating architecture requirements into modular, reviewable infrastructure as code;
- designing AWS networking, identity, encryption and workload-isolation boundaries together;
- operating EKS beyond provisioning by integrating controllers, observability, ingress, autoscaling and GitOps;
- diagnosing real deployment constraints, applying safe corrections and revalidating the result;
- distinguishing verified success from partial or non-applicable tests instead of overstating readiness;
- communicating technical outcomes through reproducible evidence, cost analysis, risk documentation and operational runbooks.

The result is intentionally framed as a validated laboratory rather than a production claim. That distinction demonstrates the risk awareness expected from a senior engineer: the repository records both achieved controls and remaining gaps, including single-NAT design, limited node redundancy, HTTP-only internal ingress and pending private-repository authentication.

## Repository structure

```text
.
├── .github/workflows/          # Terraform, platform and security CI
├── argocd/
│   ├── applications/           # AppProject and Argo CD Applications
│   └── bootstrap/              # Hardened Argo CD Helm values
├── diagrams/                   # Architecture source
├── docs/
│   ├── architecture/           # Design and architecture decisions
│   ├── evidence/               # Seven reports and command evidence
│   ├── images/                 # README banner and runtime screenshots
│   ├── operations/             # Deploy, validate and destroy runbooks
│   └── security/               # Security design
├── helm-values/                # Reviewed controller defaults
├── kubernetes/
│   ├── apps/demo-app/          # Deployment, Service, HPA, PDB and Ingress
│   ├── base/                   # Namespaces and RBAC
│   └── security/               # Default-deny and explicit network paths
├── scripts/                    # Guarded operational automation
└── terraform/
    ├── bootstrap/state/        # Protected S3/KMS backend foundation
    ├── environments/dev/       # Environment composition
    └── modules/                # VPC, EKS, ECR, IRSA and security modules
```

## Requirements

- AWS account access through IAM Identity Center.
- AWS CLI v2 with profile `kubernetes-project`.
- Terraform `>= 1.10` and `< 2.0`.
- kubectl compatible with EKS Kubernetes 1.35.
- Helm 3, Git, jq, Docker and Kustomize.
- A trusted public operator IP if using the restricted public EKS endpoint, or an approved private network path.

Run the local tool and source validation first:

```bash
./scripts/00-verify-tools.sh
./scripts/06-validate-local.sh
```

## Deployment

> [!CAUTION]
> These commands create billable AWS resources. Review the dated cost estimate, confirm the SSO identity and inspect every saved plan before apply.

### 1. Bootstrap remote state

```bash
export AWS_PROFILE=kubernetes-project
export AWS_REGION=us-east-1

./scripts/07-verify-deployment-identity.sh
terraform -chdir=terraform/bootstrap/state init
terraform -chdir=terraform/bootstrap/state plan -out=tfplan
terraform -chdir=terraform/bootstrap/state apply tfplan  # explicit approval required
```

### 2. Configure and deploy EKS

Create ignored `backend.hcl` and `terraform.tfvars` from their examples using the real backend outputs, SSO role ARN and trusted API CIDR. Never commit either file.

```bash
./scripts/01-terraform-init-plan.sh
terraform -chdir=terraform/environments/dev show tfplan
./scripts/02-terraform-apply.sh                 # explicit approval required
./scripts/03-update-kubeconfig.sh
./scripts/04-bootstrap-platform.sh
```

### 3. Validate

```bash
kubectl cluster-info
kubectl get nodes -o wide
kubectl get pods -A
kubectl get svc -A
kubectl get ingress -A
kubectl top nodes
kubectl top pods -A
```

The complete sequencing, approval gates and troubleshooting guidance are in the [deployment guide](docs/operations/deployment-guide.md) and [deployment checklist](docs/operations/deployment-checklist.md).

## Validation strategy

Validation is layered rather than inferred from a successful apply:

1. **Source:** Terraform formatting/validation, Bash syntax, YAML, Kustomize and Helm rendering.
2. **Plan:** saved-plan JSON confirms intended actions and absence of replacements/deletes.
3. **AWS:** VPC routes, EKS status, node groups, add-ons, IAM, OIDC, KMS, ECR, CloudWatch and ELB are queried directly.
4. **Kubernetes:** nodes, pods, workloads, services, ingress, events and Metrics API are inspected.
5. **Functional:** in-cluster DNS, ClusterIP Service, authenticated API Server and internal ALB return successful responses.
6. **Security:** IRSA assumes the expected role through STS; secret access is never claimed without a defined secret fixture.
7. **Convergence:** a final Terraform plan proves zero drift.

See the component-by-component [audit matrix](docs/evidence/VALIDATION_REPORT.md).

## Security

- **Identity-aware access:** operators use IAM Identity Center; deployment scripts reject the permanent IAM user.
- **Least-privilege workload access:** IRSA trust policies bind roles to exact namespace and ServiceAccount subjects. The broad operator permission set remains a documented lab risk.
- **Zero Trust posture:** private nodes, no automatic public IPs, explicit API `/32`, default-deny NetworkPolicies and minimal ingress/egress paths.
- **Encryption:** separate customer-managed KMS keys protect Terraform state and EKS Secrets; worker volumes are encrypted.
- **Metadata protection:** IMDSv2 is required with hop limit one.
- **Supply-chain controls:** ECR uses immutable tags and scan-on-push; CI runs secret and IaC security checks.
- **Workload hardening:** non-root execution, dropped capabilities, seccomp, read-only root filesystem and no token automount for the demo app.
- **Auditability:** all EKS control-plane log types are enabled and runtime evidence excludes tokens, state, plans and secret values.

The full threat/control review and remaining risks are documented in the [security report](docs/evidence/SECURITY_REPORT.md).

## Laboratory cost

The dated estimate for the active dev topology is **USD 6.50–8.00/day** or approximately **USD 195–240/month**, depending on NAT data, ALB LCUs, logs and transfer. Primary cost drivers are the EKS control plane, two on-demand `t3.medium` nodes, NAT Gateway, internal ALB, gp3 storage and two customer-managed KMS keys.

Use an AWS Budget, assign a destruction owner and do not leave the laboratory active longer than required. See the [cost report](docs/evidence/COST_REPORT.md) for the breakdown and assumptions.

## Evidence and reports

The complete version-controlled evidence package is available under **[docs/evidence/](docs/evidence/)**.

| Report | Purpose |
|---|---|
| [Project Completion Report](docs/evidence/PROJECT_COMPLETION_REPORT.md) | Executive outcome, completion level and pending work |
| [Deployment Evidence](docs/evidence/DEPLOYMENT_EVIDENCE.md) | Terraform, AWS, Kubernetes and functional proof |
| [Validation Report](docs/evidence/VALIDATION_REPORT.md) | Auditable PASS/PARTIAL/NOT APPLICABLE/FAIL matrix |
| [Security Report](docs/evidence/SECURITY_REPORT.md) | Verified controls, findings and secret-test boundary |
| [Cost Report](docs/evidence/COST_REPORT.md) | Daily/monthly estimate and cost drivers |
| [Architecture Report](docs/evidence/ARCHITECTURE_REPORT.md) | Deployed topology, availability posture and gaps |
| [Command Log](docs/evidence/COMMAND_LOG.md) | Sanitized chronological execution record |

Additional evidence: [detailed deployment command log](docs/evidence/2026-07-27-deployment-command-log.md), [hardening publication evidence](docs/evidence/2026-07-21-hardening-publication.md) and [manual screenshot checklist](docs/evidence/DEPLOYMENT_EVIDENCE.md#required-screenshots).

## Roadmap

- [ ] Configure Argo CD private-repository access through a read-only GitHub App or deploy key delivered securely.
- [ ] Add an approved Secrets Manager fixture, SecretStore and ExternalSecret for a real value-sync test without exposing content.
- [ ] Replace the public EKS API path with VPN, bastion or another private administration channel.
- [ ] Add ACM-backed HTTPS and optional WAF association for reviewed public ingress.
- [ ] Increase NAT and node-group redundancy for production availability.
- [ ] Add automated AWS Budget alerts, dashboards and longer-term log archival.
- [ ] Validate PVC provisioning, backup/restore and disaster-recovery procedures.
- [ ] Replace the broad lab operator permission set with a least-privilege deployment role.

## Destruction

The live environment must remain active until explicit authorization. When cleanup is approved, remove Kubernetes-managed load balancers first, then follow the [controlled destruction runbook](docs/operations/destroy-guide.md) and verify that no orphaned resources remain. The protected S3/KMS backend has a separate retention lifecycle.

## Author

**Emanuel González Michea**<br>
Cloud & DevOps portfolio project focused on AWS, Infrastructure as Code, Kubernetes, platform engineering and security.

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Emanuel_González_Michea-0A66C2?logo=linkedin&logoColor=white)](https://www.linkedin.com/in/emanuel-gonzalez-michea/)

## License

Distributed under the [MIT License](LICENSE).
