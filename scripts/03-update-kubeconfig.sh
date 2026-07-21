#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../terraform/environments/dev"

CLUSTER_NAME=$(terraform output -raw eks_cluster_name)
REGION=$(terraform output -raw aws_region)

aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER_NAME"

kubectl get nodes
