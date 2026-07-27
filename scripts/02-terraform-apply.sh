#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT/terraform/environments/dev"

"$REPO_ROOT/scripts/07-verify-deployment-identity.sh"

if [ ! -f tfplan ]; then
  echo "Missing reviewed tfplan. Run scripts/01-terraform-init-plan.sh first."
  exit 1
fi

terraform apply tfplan
