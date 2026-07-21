#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../terraform/environments/dev"

if [ ! -f tfplan ]; then
  echo "Missing reviewed tfplan. Run scripts/01-terraform-init-plan.sh first."
  exit 1
fi

terraform apply tfplan
