#!/usr/bin/env bash
set -euo pipefail

echo "Checking required tools..."

tools=(aws terraform git docker kubectl helm jq)

for tool in "${tools[@]}"; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "Missing required tool: $tool"
    exit 1
  fi
done

echo "AWS:"
aws --version

echo "Terraform:"
terraform version

echo "Docker:"
docker --version
docker compose version || true

echo "kubectl:"
kubectl version --client

echo "Helm:"
helm version

echo "Git:"
git --version

echo "jq:"
jq --version

echo "All required tools are installed."
