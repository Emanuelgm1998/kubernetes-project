# Cost Control and FinOps

## Default posture

The dev environment optimizes for short-lived validation:

- one shared NAT Gateway;
- one `t3.medium` system node and one `t3.medium` application node;
- WAF disabled;
- Grafana disabled;
- seven-day EKS control-plane log retention;
- EKS 1.35 in standard support (verified 2026-07-21; recheck before deployment);
- ECR lifecycle limited to ten images;
- ECR force deletion enabled only for dev.

## Metered components

Estimate all of the following for the target region and date:

| Component | Primary cost dimension | Shutdown consideration |
|---|---|---|
| EKS | Cluster hours and possible extended-support surcharge | Destroy cluster |
| EC2 nodes | Instance hours and EBS | Scale to zero where possible, then destroy |
| NAT Gateway | Gateway hours and processed data | Destroy VPC/NAT |
| ALB | Load-balancer hours and capacity units | Delete Ingress first |
| WAF | Web ACL, rules and requests | Disabled by default |
| CloudWatch | Ingested and retained logs | Seven-day retention |
| KMS | Two customer-managed keys | State and EKS Secrets encryption |
| ECR | Stored image data and scanning | Lifecycle and dev force delete |
| Data transfer | Cross-AZ and Internet egress | Shared NAT can add cross-AZ traffic |

Do not copy an undated dollar estimate into the repository. AWS prices and EKS support status change. Attach a dated AWS Pricing Calculator estimate to each deployment approval.

The previous EKS 1.31 default was removed because it is in extended support and would add an avoidable surcharge. The S3 state bucket and its KMS key are intentionally retained after environment destruction and must remain in the account inventory. Include both customer-managed KMS keys in the dated cost estimate.

## Budget guardrails for a real account

Before deployment, configure outside this stack:

- an AWS Budget with email/chat notification;
- project and environment cost-allocation tags;
- an approved maximum lifetime for the environment;
- a named owner responsible for destruction;
- post-destroy verification for orphaned resources.

## Availability trade-off

One NAT Gateway is deliberately not production-grade. Production should normally use one per AZ or a reviewed alternative using VPC endpoints and centralized egress. The choice must be based on availability requirements and measured data transfer, not only hourly price.
