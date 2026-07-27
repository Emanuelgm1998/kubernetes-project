#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT/terraform/environments/dev"

"$REPO_ROOT/scripts/07-verify-deployment-identity.sh"

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=$(terraform output -raw aws_region)

aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
