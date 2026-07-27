# Deployment command log — 2026-07-27

Scope: AWS account `747747309806`, region `us-east-1`, profile `kubernetes-project`.

Sensitive Terraform state, plan contents, SSO tokens and kubeconfig contents are intentionally excluded.

## Preflight

- `aws sts get-caller-identity` — passed; validated the expected account and `AWSReservedSSO_AdministratorAccess_*` session.
- `aws configure get region` — passed; `us-east-1`.
- Read-only AWS inventory across EKS, EC2/VPC, ECR, IAM, KMS, S3, CloudWatch and ELB — no pre-existing project infrastructure found.
- `terraform fmt -check -recursive terraform` — passed.
- `terraform validate` for bootstrap and dev — passed outside the execution sandbox.
- Tool, Bash syntax and Kustomize render checks — passed.

## Terraform state backend

- `terraform -chdir=terraform/bootstrap/state plan -out=tfplan` — `8 to add, 0 to change, 0 to destroy`.
- `terraform -chdir=terraform/bootstrap/state apply tfplan` — completed; `8 added, 0 changed, 0 destroyed`.
- Read-only S3 validation — versioning enabled, all public-access blocks enabled, SSE-KMS enabled with bucket keys, noncurrent-version expiry set to 90 days.
- Read-only KMS validation — key enabled, rotation enabled, usage `ENCRYPT_DECRYPT`.
- Post-apply `terraform plan` — no changes.

The backend resources are intentionally protected with `prevent_destroy` and are not part of the later environment destruction phase.

## EKS environment plan

- Generated ignored local `backend.hcl` from the real backend outputs.
- Generated ignored local `terraform.tfvars` with the real SSO role ARN.
- Enabled the EKS public API endpoint for workstation validation, restricted to the observed operator address `190.101.28.15/32`; private endpoint access remains enabled.
- `terraform init -reconfigure -backend-config=backend.hcl` — remote S3 backend initialized successfully with native lockfile support.
- `terraform validate` — passed.
- `terraform plan -out=tfplan` — `49 to add, 0 to change, 0 to destroy`.
- JSON plan review — 49 create actions, 5 deferred data reads, no update or delete actions.

The EKS environment plan has not been applied and requires separate explicit authorization.

## Final pre-apply review

- `terraform fmt -check -recursive terraform` initially detected formatting drift only in the ignored `terraform.tfvars`; `terraform fmt terraform/environments/dev/terraform.tfvars` corrected it without changing values.
- Bootstrap and environment `terraform validate` — passed after formatting.
- `scripts/06-validate-local.sh` — passed; `shellcheck` and `yamllint` were not installed and their optional checks were explicitly skipped. Bash syntax and workflow YAML parsing were checked separately and passed.
- Saved-plan JSON audit — 49 create actions, 0 update actions, 0 delete actions and 0 replacements.
- GitHub workflow files parsed successfully. Current remote Actions status could not be queried: `gh` is not installed and the unauthenticated public GitHub API returned HTTP 404 for the repository.

## EKS apply and bootstrap

- `terraform apply tfplan` — completed after approximately 15 minutes; `49 added, 0 changed, 0 destroyed`.
- AWS validation — EKS `ACTIVE`; both managed node groups `ACTIVE`; VPC CNI, CoreDNS, kube-proxy and EBS CSI add-ons `ACTIVE` with no health issues.
- `scripts/03-update-kubeconfig.sh` — completed; kubeconfig contents were not recorded.
- Initial `kubectl cluster-info`, version, nodes and pod inventory — API reachable; two nodes `Ready`; core EKS pods running.
- First `scripts/04-bootstrap-platform.sh` attempt — AWS Load Balancer Controller and External Secrets installed, but Argo CD failed its atomic Helm timeout. Evidence showed the application controller `Pending` because the untainted application node reached its 17-pod capacity; Helm automatically rolled back the Argo CD release.
- Corrective action — configured the Argo CD chart globally for `role=system` with an exact `CriticalAddonsOnly=true:NoSchedule` toleration, matching the dedicated system node group.
- Second bootstrap attempt — Argo CD Helm release deployed successfully; `demo-app` and `metrics-server` Applications were created.
- Argo CD reconciliation found two additional issues: the private GitHub repository requires credentials not present in the cluster, leaving `demo-app` at `Unknown`; Metrics Server was blocked because the restricted AppProject did not permit `apiregistration.k8s.io/APIService`.
- Corrective action — added only `apiregistration.k8s.io/APIService` to the AppProject cluster resource whitelist. No broad wildcard permission was added.
- The demo manifests are applied from the reviewed local checkout for functional Kubernetes/ALB validation. GitOps reconciliation of the demo remains separately reported as blocked pending a safe GitHub credential or public repository access.
- Metrics Server then reached Argo CD `Synced/Healthy`; two replicas are Running and live node/pod metrics plus HPA CPU values were returned.
- In-cluster functional test — Kubernetes DNS, demo Service, internal ALB and authenticated API Server each passed; all HTTP checks returned 200.
- First IRSA test attempt failed because the test command incorrectly replaced the AWS CLI image entrypoint. The corrected attempt assumed `kubernetes-platform-dev-external-secrets-irsa` through STS.
- Controlled Secrets Manager test — `ResourceNotFoundException`, not `AccessDenied`; no secret was defined, created or read.
- Final ALB validation — active internal ALB in two AZs; target group has 2/2 healthy IP targets.
- Final CloudWatch validation — control-plane Log Group has seven-day retention and recent streams; five recent kube-apiserver event timestamps were retrieved without logging message content.
- Final Kubernetes validation — 2/2 nodes Ready and 26/26 pods Running/Ready.
- Final Terraform saved-plan JSON — 0 add, 0 change, 0 destroy, 0 replace.
- No destroy or deletion command was executed.
