#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../terraform/environments/dev"

if [ ! -f backend.hcl ]; then
  echo "Missing backend.hcl. Bootstrap the state bucket and copy backend.hcl.example first."
  exit 1
fi

if [ ! -f terraform.tfvars ]; then
  cp terraform.tfvars.example terraform.tfvars
  echo "Created terraform.tfvars from example. Review it before applying."
fi

terraform fmt -recursive
terraform init -input=false -reconfigure -backend-config=backend.hcl
terraform validate
terraform plan -input=false -out=tfplan

echo "Plan saved to terraform/environments/dev/tfplan. Review it with: terraform show tfplan"
