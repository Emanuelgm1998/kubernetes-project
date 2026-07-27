#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TF_DIR="$REPO_ROOT/terraform/environments/dev"

"$REPO_ROOT/scripts/07-verify-deployment-identity.sh"

AWS_LBC_CHART_VERSION="${AWS_LBC_CHART_VERSION:-3.4.2}"
EXTERNAL_SECRETS_CHART_VERSION="${EXTERNAL_SECRETS_CHART_VERSION:-2.8.0}"
ARGOCD_CHART_VERSION="${ARGOCD_CHART_VERSION:-10.1.4}"

CLUSTER_NAME="$(terraform -chdir="$TF_DIR" output -raw eks_cluster_name)"
VPC_ID="$(terraform -chdir="$TF_DIR" output -raw vpc_id)"
LBC_ROLE_ARN="$(terraform -chdir="$TF_DIR" output -raw load_balancer_controller_role_arn)"
EXTERNAL_SECRETS_ROLE_ARN="$(terraform -chdir="$TF_DIR" output -raw external_secrets_role_arn)"

kubectl apply -f "$REPO_ROOT/kubernetes/base/namespaces/namespaces.yaml"
kubectl apply -f "$REPO_ROOT/kubernetes/base/rbac/read-only-role.yaml"

helm repo add eks https://aws.github.io/eks-charts
helm repo add external-secrets https://charts.external-secrets.io
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  --namespace kube-system \
  --version "$AWS_LBC_CHART_VERSION" \
  --set "clusterName=$CLUSTER_NAME" \
  --set "vpcId=$VPC_ID" \
  --set-string "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn=$LBC_ROLE_ARN" \
  --atomic --wait

helm upgrade --install external-secrets external-secrets/external-secrets \
  --namespace external-secrets \
  --version "$EXTERNAL_SECRETS_CHART_VERSION" \
  --set installCRDs=true \
  --set-string "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn=$EXTERNAL_SECRETS_ROLE_ARN" \
  --atomic --wait

echo "Install ArgoCD:"
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd \
  --create-namespace \
  --version "$ARGOCD_CHART_VERSION" \
  --values "$REPO_ROOT/argocd/bootstrap/values.yaml" \
  --atomic --wait

kubectl apply -f "$REPO_ROOT/argocd/applications/platform-project.yaml"
kubectl apply -k "$REPO_ROOT/argocd/applications"
