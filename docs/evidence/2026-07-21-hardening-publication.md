# Hardening Publication Evidence — 2026-07-21

## Scope

This record covers the local audit, hardening and publication of the EKS GitOps platform. No `terraform apply`, `terraform destroy`, Kubernetes mutation or mutable AWS API operation was executed.

## Published baseline

- Repository: `Emanuelgm1998/kubernetes-project`
- Branch: `main`
- Initial hardening commit: `0e1aed091abec49bcf8e32127f00bf58b4d318aa`
- Commit subject: `feat: harden EKS GitOps platform and remote Terraform state`

The evidence correction that contains this document can be resolved with:

```bash
git log -1 --format='%H %s' -- docs/evidence/2026-07-21-hardening-publication.md
```

## Local validation evidence

The following checks completed successfully before publication:

- `git diff --check`
- `terraform fmt -check -recursive terraform`
- `terraform init -backend=false` and `terraform validate` for `terraform/bootstrap/state`
- `terraform init -backend=false` and `terraform validate` for `terraform/environments/dev`
- `kubectl kustomize kubernetes`
- `kubectl kustomize argocd/applications`
- Helm rendering for AWS Load Balancer Controller `3.4.2`
- Helm rendering for External Secrets `2.8.0`
- Helm rendering for Argo CD chart `10.1.4`
- Helm rendering for Metrics Server chart `3.13.1`
- `bash -n` for every script under `scripts/`
- credential, token, private-key and sensitive-file scans
- exact normalized comparison between the local AWS Load Balancer Controller policy and the upstream `v3.4.2` policy

Sensitive local paths (`terraform.tfvars`, `backend.hcl`, plans, state, `.terraform`, kubeconfig and secret files) were confirmed ignored and absent from the Git index.

## GitHub Actions evidence

Runs triggered by the initial hardening commit:

| Workflow | Result | Evidence |
|---|---|---|
| Terraform CI | Success | [Run 29826419746](https://github.com/Emanuelgm1998/kubernetes-project/actions/runs/29826419746) |
| Platform Manifests CI | Success | [Run 29826419752](https://github.com/Emanuelgm1998/kubernetes-project/actions/runs/29826419752) |
| Security CI | Setup failure, corrected | [Run 29826419743](https://github.com/Emanuelgm1998/kubernetes-project/actions/runs/29826419743) |

The Security CI failure was not a security finding. Its annotation reported an unresolved action reference because `aquasecurity/trivy-action@0.33.1` omitted the required `v` prefix. The workflow was corrected to the immutable commit SHA for `v0.36.0`.

The next Trivy execution produced three HIGH hardening findings. They were resolved by using customer-managed KMS keys for S3 state and EKS Secret envelope encryption, and by disabling automatic public IP assignment in public subnets. A local Trivy `v0.70.0` rescan with the workflow's `HIGH,CRITICAL` threshold reported zero failures before publication.

## Deployment boundary

The remote S3 backend does not yet exist. Creating it is the next infrastructure phase and requires separate explicit approval. The real IAM Identity Center role must be identified before setting `ADMIN_ROLE_ARN`; documentation placeholders are not deployable values.
