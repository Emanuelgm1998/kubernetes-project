#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

terraform fmt -check -recursive "$REPO_ROOT/terraform"
terraform -chdir="$REPO_ROOT/terraform/bootstrap/state" init -backend=false -input=false
terraform -chdir="$REPO_ROOT/terraform/bootstrap/state" validate
terraform -chdir="$REPO_ROOT/terraform/environments/dev" init -backend=false -input=false -reconfigure
terraform -chdir="$REPO_ROOT/terraform/environments/dev" validate

kubectl kustomize "$REPO_ROOT/kubernetes" >/dev/null
kubectl kustomize "$REPO_ROOT/argocd/applications" >/dev/null

if command -v shellcheck >/dev/null 2>&1; then
  shellcheck "$REPO_ROOT"/scripts/*.sh
else
  echo "WARN: shellcheck is not installed; shell validation was skipped."
fi

if command -v yamllint >/dev/null 2>&1; then
  yamllint -c "$REPO_ROOT/.yamllint" \
    "$REPO_ROOT/.github" "$REPO_ROOT/argocd" \
    "$REPO_ROOT/helm-values" "$REPO_ROOT/kubernetes"
else
  echo "WARN: yamllint is not installed; YAML lint was skipped."
fi

git -C "$REPO_ROOT" diff --check
echo "Local validation completed."
