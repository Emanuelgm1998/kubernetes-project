#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT/terraform/environments/dev"

"$REPO_ROOT/scripts/07-verify-deployment-identity.sh"

if [ ! -f backend.hcl ]; then
  echo "Missing backend.hcl. Bootstrap the state bucket and copy backend.hcl.example first."
  exit 1
fi

if grep -q 'REPLACE_WITH' backend.hcl; then
  echo "backend.hcl still contains a placeholder."
  exit 1
fi

if [ ! -f terraform.tfvars ]; then
  cp terraform.tfvars.example terraform.tfvars
  echo "Created terraform.tfvars from example. Review it before applying."
fi

if grep -q 'REPLACE_ME' terraform.tfvars; then
  echo "terraform.tfvars still contains REPLACE_ME."
  exit 1
fi

terraform fmt -recursive
terraform init -input=false -reconfigure -backend-config=backend.hcl
terraform validate
terraform plan -input=false -out=tfplan

echo "Plan saved to terraform/environments/dev/tfplan. Review it with: terraform show tfplan"
