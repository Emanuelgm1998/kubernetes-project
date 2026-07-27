#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT/terraform/environments/dev"

"$REPO_ROOT/scripts/07-verify-deployment-identity.sh"

CLUSTER_NAME=$(terraform output -raw eks_cluster_name)
REGION=$(terraform output -raw aws_region)

aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER_NAME"

kubectl get nodes
