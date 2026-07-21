# Architecture Decisions

## ADR-001: Private EKS API by default

The development environment disables the public endpoint. Temporary public access requires explicit activation and trusted `/32` CIDRs. Operators otherwise need VPN, Direct Connect, a runner inside the VPC or another approved private path.

## ADR-002: One NAT Gateway for portfolio validation

Development uses one NAT Gateway to reduce hourly cost. This introduces a cross-AZ dependency and possible cross-AZ data charges. Production should use one NAT Gateway per active AZ or evaluate VPC endpoints and an egress architecture based on traffic patterns.

## ADR-003: IRSA for AWS-integrated controllers

VPC CNI, AWS Load Balancer Controller, External Secrets and EBS CSI receive separate IAM roles whose trust policies bind exact Kubernetes service accounts. The node role retains only worker-node and ECR read policies.

## ADR-004: GitOps after infrastructure bootstrap

Terraform owns AWS infrastructure and identity. A guarded bootstrap installs controllers that require Terraform outputs, then installs ArgoCD. ArgoCD owns application and selected platform manifests. This prevents Terraform from depending on a Kubernetes API that does not exist yet.

## ADR-005: Internal ingress by default

The demo ALB is internal. Public exposure requires a reviewed overlay with a DNS name, ACM certificate, HTTPS redirect and WAF Web ACL association. This prevents an unfinished HTTP endpoint from becoming public by default.

## ADR-006: Protected remote state

The environment uses an S3 backend configured by an ignored `backend.hcl`, native S3 lockfiles, encryption, versioning and blocked public access. A separate stack bootstraps the bucket and protects it with `prevent_destroy`; its small local bootstrap state must be retained securely.

## ADR-007: Explicit EKS administration

Implicit cluster-creator administration is disabled. A reviewed IAM role, preferably from IAM Identity Center, receives `AmazonEKSClusterAdminPolicy` through the EKS access API. Workloads never inherit operator access.
