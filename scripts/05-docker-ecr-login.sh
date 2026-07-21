#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../terraform/environments/dev"

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=$(terraform output -raw aws_region)

aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
