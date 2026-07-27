#!/usr/bin/env bash
set -euo pipefail

EXPECTED_ACCOUNT_ID="747747309806"
EXPECTED_REGION="us-east-1"
EXPECTED_PROFILE="kubernetes-project"

if [ "${AWS_PROFILE:-}" != "$EXPECTED_PROFILE" ]; then
  echo "ERROR: AWS_PROFILE must be $EXPECTED_PROFILE." >&2
  exit 1
fi

configured_region="${AWS_REGION:-${AWS_DEFAULT_REGION:-}}"
if [ -z "$configured_region" ]; then
  configured_region="$(aws configure get region --profile "$EXPECTED_PROFILE")"
fi

if [ "$configured_region" != "$EXPECTED_REGION" ]; then
  echo "ERROR: AWS region must be $EXPECTED_REGION, got ${configured_region:-<unset>}." >&2
  exit 1
fi

identity="$(aws sts get-caller-identity --output json)"
account_id="$(jq -r '.Account' <<<"$identity")"
caller_arn="$(jq -r '.Arn' <<<"$identity")"

if [ "$account_id" != "$EXPECTED_ACCOUNT_ID" ]; then
  echo "ERROR: expected AWS account $EXPECTED_ACCOUNT_ID, got $account_id." >&2
  exit 1
fi

case "$caller_arn" in
  arn:aws:sts::"$EXPECTED_ACCOUNT_ID":assumed-role/AWSReservedSSO_AdministratorAccess_*/*)
    ;;
  *)
    echo "ERROR: active identity is not the AdministratorAccess IAM Identity Center role." >&2
    echo "Run: aws sso login --profile $EXPECTED_PROFILE" >&2
    exit 1
    ;;
esac

printf 'Validated AWS SSO deployment identity: %s in %s\n' "$caller_arn" "$EXPECTED_REGION"
