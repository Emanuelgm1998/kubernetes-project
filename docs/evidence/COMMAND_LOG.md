# Command Log

Chronological deployment record for 2026-07-27. Commands were run with `AWS_PROFILE=kubernetes-project` and `AWS_REGION=us-east-1`. State, plan contents, kubeconfig, tokens and secret values are excluded.

## Identity and preflight

1. `aws sso login --profile kubernetes-project --use-device-code`
2. `aws sts get-caller-identity`
3. `aws configure get region`
4. `scripts/07-verify-deployment-identity.sh`
5. Read-only AWS inventory commands for EKS, EC2, IAM, KMS, S3, ECR, ELB and CloudWatch.
6. `terraform fmt -check -recursive terraform`
7. `terraform validate` in bootstrap and dev.
8. `scripts/00-verify-tools.sh` and `scripts/06-validate-local.sh`.
9. Kustomize, Bash syntax and workflow YAML parsing checks.
10. `terraform show -json tfplan | jq ...` — 49 create, 0 update/delete/replace.

## Backend

11. `terraform -chdir=terraform/bootstrap/state plan -out=tfplan`
12. `terraform -chdir=terraform/bootstrap/state apply tfplan`
13. S3 versioning/public-access/encryption/lifecycle read checks.
14. KMS state/rotation read checks.
15. Post-backend `terraform plan` — no changes.

## EKS infrastructure

16. `terraform init -reconfigure -backend-config=backend.hcl`
17. `terraform validate`
18. `terraform plan -out=tfplan`
19. `terraform apply tfplan` — 49/0/0.
20. `scripts/03-update-kubeconfig.sh`
21. AWS CLI validation of VPC, routes, NAT, EIP, IAM, OIDC, KMS, ECR, CloudWatch, EKS, node groups and add-ons.
22. `terraform output -json` with sensitive handling and `terraform state list`.

## Kubernetes bootstrap and corrections

23. Baseline `kubectl cluster-info`, version, nodes and pods.
24. First `scripts/04-bootstrap-platform.sh` — Argo CD atomic timeout due pod capacity; rollback completed.
25. Pod/event/node diagnostics identified max-pod scheduling pressure.
26. Argo values corrected with system node selector and exact taint toleration.
27. Second `scripts/04-bootstrap-platform.sh` — all Helm releases deployed; Applications created.
28. Argo conditions/logs identified private-repository authentication block and Metrics APIService restriction.
29. AppProject corrected with minimum APIService permission.
30. Metrics Application refreshed and became `Synced/Healthy`.
31. Reviewed demo manifests applied locally for functional testing.

## Functional and final validation

32. Deployment/daemonset/statefulset rollouts and waits.
33. In-cluster DNS, Service HTTP, internal ALB HTTP and API Server tests — all HTTP 200.
34. First IRSA pod attempt failed because `sts` incorrectly replaced the image entrypoint.
35. Corrected IRSA pod test assumed the External Secrets role successfully.
36. Negative Secrets Manager test returned `ResourceNotFoundException`; no secret was created.
37. Required Kubernetes inventories, events, top metrics, HPA, Argo and Helm status.
38. ELB/target-group validation — active ALB, 2/2 targets healthy.
39. CloudWatch validation — control-plane streams and five recent event timestamps.
40. Final Terraform plan saved as ignored `postdeploy.tfplan`; JSON counts `0/0/0/0`.
41. Final health query — EKS ACTIVE, 2/2 nodes Ready, 26/26 pods Running/Ready.

The more detailed running record is [2026-07-27-deployment-command-log.md](2026-07-27-deployment-command-log.md).

No destroy or resource-deletion command was run.
