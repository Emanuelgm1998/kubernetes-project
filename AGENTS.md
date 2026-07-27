# Project Session Context

Before taking any action in this repository, read `docs/CURRENT_CONTEXT.md` completely and treat it as the current project handoff.

Mandatory rules:

- Preserve all existing local changes; inspect `git status` before editing.
- Do not execute `terraform apply`, `terraform destroy` or mutable AWS operations unless Emanuel provides explicit authorization for that exact phase.
- Do not create, delete or modify AWS resources implicitly.
- Do not use the permanent IAM user to deploy; require the `kubernetes-project` AWS SSO profile and the validated `AWSReservedSSO_PlatformAdministrator_*` session.
- Do not commit or push unless Emanuel explicitly authorizes publication.
- Do not expose credentials, SSO tokens, access keys, Terraform state, plans or kubeconfig contents.
- If infrastructure is later deployed for evidence, leave it active until Emanuel explicitly authorizes controlled destruction.
- Continue from the documented state instead of repeating completed work.

Operational references:

- `docs/CURRENT_CONTEXT.md`
- `docs/operations/identity-center-setup.md`
- `docs/operations/deployment-checklist.md`
- `docs/operations/deployment-guide.md`
- `docs/evidence/deployment-template.md`
- `docs/operations/destroy-guide.md`
