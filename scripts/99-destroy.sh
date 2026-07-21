#!/usr/bin/env bash
set -euo pipefail

echo "Destroying Terraform-managed infrastructure."
echo "Make sure Kubernetes-created load balancers are deleted before destroying VPC."
read -r -p "Continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
  echo "Aborted."
  exit 1
fi

cd "$(dirname "$0")/../terraform/environments/dev"
terraform plan -destroy -input=false -out=destroy.tfplan
terraform show destroy.tfplan

read -r -p "Apply the reviewed destroy plan? (yes/no): " apply_confirm
if [ "$apply_confirm" != "yes" ]; then
  echo "Destroy plan retained for review; no resources were changed."
  exit 1
fi

terraform apply destroy.tfplan
