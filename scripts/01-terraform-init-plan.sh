#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../terraform/environments/dev"

if [ ! -f terraform.tfvars ]; then
  cp terraform.tfvars.example terraform.tfvars
  echo "Created terraform.tfvars from example. Review it before applying."
fi

terraform fmt -recursive
terraform init -input=false
terraform validate
terraform plan -input=false -out=tfplan

echo "Plan saved to terraform/environments/dev/tfplan. Review it with: terraform show tfplan"
