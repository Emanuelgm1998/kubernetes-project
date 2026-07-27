# IAM Identity Center Setup

## Read-only inventory

Verified on 2026-07-21 in `us-east-1`:

| Item | Observed value |
|---|---|
| Account | `747747309806` |
| Identity Center status | `ACTIVE` |
| Instance ARN | `arn:aws:sso:::instance/ssoins-7223b09690b01fbd` |
| Identity Store ID | `d-906670dd89` |
| Permission Sets | None |
| Identity Store users | None |
| Account assignments | None possible until a Permission Set and user exist |
| `AWSReservedSSO` roles | None |
| Local SSO profile | None; only `default` exists |

The active `default` profile is an IAM user and is prohibited for EKS administration. The AWS access portal URL is intentionally not recorded because it has not been retrieved from the console and must not be guessed.

## 1. Create and activate the Identity Center user

In AWS Console, select `us-east-1` and open **IAM Identity Center → Users**.

1. Choose **Add user**.
2. Enter the operator's real username, email, first name and last name.
3. Send the activation instructions.
4. Complete the activation and configure MFA.
5. Confirm that the user status is enabled before assigning AWS access.

Do not invent the email or username in automation. Record the generated User ID only in the deployment approval record if required; it is not needed in Terraform.

## 2. Create the Permission Set

Open **IAM Identity Center → Permission sets → Create permission set**.

Use:

- Permission set type: `Custom permission set`
- Name: `PlatformAdministrator`
- Description: `Administration for the temporary EKS portfolio laboratory`
- Session duration: `2 hours`
- AWS managed policy: `AdministratorAccess`
- Relay state: empty

This broad policy is accepted for the short-lived, manually approved laboratory deployment. It must not be used by CI and should be replaced with a narrower deployment policy before treating the platform as production-ready.

## 3. Assign access to the target account

Open **IAM Identity Center → AWS accounts**.

1. Select account `747747309806`.
2. Choose **Assign users or groups**.
3. Select the activated operator user.
4. Select `PlatformAdministrator`.
5. Submit and wait for provisioning to complete.

The assignment creates the `AWSReservedSSO_PlatformAdministrator_*` IAM role. Do not construct its ARN because the path and suffix are AWS-generated.

## 4. Obtain the real role ARN

Run with the existing read-only-capable identity after provisioning:

```bash
export ADMIN_ROLE_ARN="$(
  aws iam list-roles \
    --query 'Roles[?starts_with(RoleName, `AWSReservedSSO_PlatformAdministrator_`)].Arn | [0]' \
    --output text
)"

if [ -z "$ADMIN_ROLE_ARN" ] || [ "$ADMIN_ROLE_ARN" = "None" ]; then
  echo "PlatformAdministrator AWSReservedSSO role was not found" >&2
  exit 1
fi

case "$ADMIN_ROLE_ARN" in
  *REPLACE_ME*) echo "Invalid placeholder in ADMIN_ROLE_ARN" >&2; exit 1 ;;
esac

aws iam get-role \
  --role-name "${ADMIN_ROLE_ARN##*/}" \
  --query 'Role.Arn' \
  --output text
```

Preserve the ARN exactly as returned, including any path between `role/` and the role name.

## 5. Configure AWS CLI SSO

In **IAM Identity Center → Settings**, copy the exact **AWS access portal URL**. Then run:

```bash
aws configure sso
```

Provide:

| Prompt | Value |
|---|---|
| SSO session name | `kubernetes-project` |
| SSO start URL | Exact AWS access portal URL copied from the console |
| SSO region | `us-east-1` |
| SSO registration scopes | `sso:account:access` |
| AWS account | `747747309806` |
| Role | `PlatformAdministrator` |
| Default client region | `us-east-1` |
| CLI output format | `json` |
| CLI profile name | `kubernetes-project` |

Never place the Start URL or cached SSO tokens in the repository.

## 6. Validate the SSO session

```bash
export AWS_PROFILE=kubernetes-project
export AWS_REGION=us-east-1

aws sso login --profile "$AWS_PROFILE"
aws sts get-caller-identity
aws configure list
./scripts/07-verify-deployment-identity.sh
```

Acceptance criteria:

- account is `747747309806`;
- region is `us-east-1`;
- ARN is an STS assumed-role session for `AWSReservedSSO_PlatformAdministrator_*`;
- no access key from the `default` IAM user is selected.

## 7. Populate the three local placeholders

After the backend has been approved and applied, the only local substitutions are:

1. `cluster_admin_principal_arn` in ignored `terraform.tfvars` → `$ADMIN_ROLE_ARN`.
2. bucket in ignored `backend.hcl` → `state_bucket_name` output.
3. KMS ARN in ignored `backend.hcl` → `state_kms_key_arn` output.

Verify that both local files are ignored and contain no placeholders:

```bash
git check-ignore terraform/environments/dev/terraform.tfvars
git check-ignore terraform/environments/dev/backend.hcl

if grep -E 'REPLACE_ME|REPLACE_WITH' \
  terraform/environments/dev/terraform.tfvars \
  terraform/environments/dev/backend.hcl; then
  echo "Deployment configuration still contains placeholders" >&2
  exit 1
fi
```
