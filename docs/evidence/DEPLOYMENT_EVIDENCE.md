# Deployment Evidence

Date: 2026-07-27

## Terraform evidence

- Backend apply: `8 added, 0 changed, 0 destroyed`.
- EKS apply: `49 added, 0 changed, 0 destroyed`.
- Final saved-plan JSON: `add=0`, `change=0`, `destroy=0`, `replace=0`.
- State inventory: 49 managed environment resources plus deferred data sources; no Terraform state content is included.
- Outputs recorded: cluster name, region, VPC/subnet IDs, ECR URI and IRSA/KMS ARNs.

## AWS evidence

- Cluster `kubernetes-platform-dev`: `ACTIVE`, Kubernetes `1.35`, public endpoint restricted to `190.101.28.15/32`, private endpoint enabled.
- Node groups `kubernetes-platform-dev-system-ng` and `kubernetes-platform-dev-app-ng`: `ACTIVE`, `t3.medium`, no health issues.
- Add-ons: `vpc-cni`, `coredns`, `kube-proxy`, `aws-ebs-csi-driver` all `ACTIVE`, no health issues.
- VPC `vpc-0afaa326bd5f01d3b`: available; DNS support and DNS hostnames enabled.
- NAT Gateway `nat-01427916eff201083`: available; IGW `igw-0835a25651e8bbf84` attached.
- Four subnets span `us-east-1a` and `us-east-1b`; node subnets do not assign public IPs.
- ECR `kubernetes-platform-dev-app`: immutable tags, scan-on-push and AES256 encryption.
- CloudWatch log group `/aws/eks/kubernetes-platform-dev/cluster`: 7-day retention. Five recent timestamps were retrieved from the latest kube-apiserver stream; audit, authenticator, scheduler and controller-manager streams also exist.
- Internal ALB `k8s-apps-demoapp-330cffa3fd`: active in two AZs.
- Target group `arn:aws:elasticloadbalancing:us-east-1:747747309806:targetgroup/k8s-apps-demoapp-6178cb5033/49d7321ffe453001`: 2/2 IP targets healthy on port 8080.

## Kubernetes evidence

- Server: EKS Kubernetes `v1.35.6`; client `v1.36.2`.
- Nodes: 2 total, 2 Ready, no external IPs.
- Pods: 26 total, 26 Running, zero unready containers.
- Metrics: `kubectl top nodes` and `kubectl top pods -A` returned live CPU/memory data.
- HPA: demo application reported `cpu: 1%/60%`, replicas `2`, range `2–5`.
- Argo CD, External Secrets and AWS Load Balancer Controller Helm releases: `deployed`.
- Metrics Server Application: `Synced/Healthy`.
- Demo Application: `Unknown/Healthy`; local workload healthy, repository comparison blocked by authentication.

## Functional evidence

- `nslookup kubernetes.default.svc.cluster.local`: resolved to `172.20.0.1`.
- `nslookup demo-app.apps.svc.cluster.local`: resolved to `172.20.208.154`.
- ClusterIP Service: HTTP 200.
- Internal ALB: HTTP 200 from an in-cluster pod.
- Authenticated Kubernetes API `/version`: HTTP 200.
- IRSA STS call: assumed `kubernetes-platform-dev-external-secrets-irsa`.
- Secrets boundary test: returned `ResourceNotFoundException`, not `AccessDenied`; no secret was created or read.

## Required screenshots

Take screenshots with account and region visible but redact usernames, browser session data and credentials.

AWS Console:

1. VPC details for `vpc-0afaa326bd5f01d3b`.
2. All four project subnets and both AZs.
3. Public/private route tables and active default routes.
4. NAT Gateway `nat-01427916eff201083` in `Available` state.
5. EKS overview showing `ACTIVE`, version 1.35 and endpoint configuration.
6. Both managed node groups in `ACTIVE` state.
7. Project IAM roles and attached policies.
8. IAM OIDC provider ending in `67C4362ACF6437EB15BEF3E6D4EF7CA9`.
9. Both customer-managed KMS aliases and rotation status.
10. ECR repository configuration.
11. CloudWatch log group and recent log streams; do not capture sensitive log messages.
12. Internal ALB and its target group showing 2/2 healthy targets.

Terminal:

1. Final portion of `terraform apply tfplan` showing `49 added, 0 changed, 0 destroyed`.
2. Sanitized `terraform output`.
3. `kubectl get nodes -o wide`.
4. `kubectl get pods -A`.
5. `kubectl get svc -A`.
6. `kubectl cluster-info`.
7. `kubectl get ingress -A`.
8. Sanitized `aws eks describe-cluster --name kubernetes-platform-dev` query showing status/version/endpoints.
9. Target health query showing both targets healthy.
10. Final plan JSON counts showing all zeros.
