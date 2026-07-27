# Cost Report

Estimate date: 2026-07-27, region `us-east-1`. Actual billing depends on seconds/hours used, data volume, log ingestion and ALB LCUs.

| Component | Approximate monthly cost |
|---|---:|
| EKS standard-support control plane | USD 73 |
| Two on-demand `t3.medium` nodes | USD 61 |
| Two 30 GiB gp3 root volumes | USD 5 |
| One NAT Gateway | USD 33 plus data processing |
| One internal ALB | USD 16–23 plus LCUs |
| Two customer-managed KMS keys | USD 2 plus requests |
| NAT public IPv4 | About USD 3.65 |
| S3, ECR, CloudWatch and transfer | Variable; low-volume lab estimate USD 2–15 |

Estimated active total: **USD 195–240/month**, approximately **USD 6.50–8.00/day**.

Variable charges:

- NAT Gateway data processing: approximately USD 0.045/GB plus applicable transfer.
- ALB LCUs and processed data.
- CloudWatch ingestion/storage and Internet/cross-AZ transfer.
- ECR image storage and scanning-related usage where applicable.

Cost controls already present: one NAT Gateway, two small nodes, WAF disabled, seven-day logs, ECR lifecycle retention and short-lived lab intent.

Recommendations: set an AWS Budget alarm immediately, assign an owner and destruction window, monitor Cost Explorer daily, and do not leave this laboratory active longer than required for evidence.
