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
terraform destroy
