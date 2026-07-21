# Architecture Decisions

## ADR-001: Private EKS API by default

The development environment disables the public endpoint. Temporary public access requires explicit activation and trusted `/32` CIDRs. This reduces exposure but means operators and CI need private connectivity or an approved temporary access path.

## ADR-002: One NAT Gateway for portfolio validation

Development uses one NAT Gateway to reduce hourly cost. This introduces a cross-AZ dependency and possible cross-AZ data charges. Production should use one NAT Gateway per active AZ or evaluate VPC endpoints and an egress architecture based on traffic patterns.

## ADR-003: IRSA for AWS-integrated controllers

AWS Load Balancer Controller, External Secrets and EBS CSI receive separate IAM roles whose trust policies bind exact Kubernetes service accounts. Node-level permissions are not used for these controllers. The VPC CNI policy remains on the node role to avoid a bootstrap dependency and is a candidate for a later module split.

## ADR-004: GitOps after infrastructure bootstrap

Terraform owns AWS infrastructure and identity. A guarded bootstrap installs controllers that require Terraform outputs, then installs ArgoCD. ArgoCD owns application and selected platform manifests. This prevents Terraform from depending on a Kubernetes API that does not exist yet.

## ADR-005: Internal ingress by default

The demo ALB is internal. Public exposure requires a reviewed overlay with a DNS name, ACM certificate, HTTPS redirect and WAF Web ACL association. This prevents an unfinished HTTP endpoint from becoming public by default.

## ADR-006: Local state only for initial portfolio validation

The repository does not silently assume a pre-existing backend. A shared environment must first bootstrap a versioned, encrypted S3 backend with locking and recovery controls. Backend migration is a separately reviewed operation.
