# Destroy Guide

Destruction requires explicit authorization. Kubernetes-created AWS resources must be removed before the Terraform-managed cluster and VPC.

## 1. Confirm target

```bash
aws sts get-caller-identity
kubectl config current-context
terraform -chdir=terraform/environments/dev workspace show
```

Stop if the account, cluster or workspace is unexpected.

## 2. Remove GitOps workloads and external load balancers

Pause ArgoCD reconciliation, then delete Applications and Ingress resources using an approved change window. The exact `kubectl delete` commands are intentionally not automated by this repository.

Wait until AWS Load Balancer Controller has removed ALBs, target groups and related security groups. Verify that no Kubernetes Service of type LoadBalancer remains.

## 3. Check persistent and external resources

- PersistentVolumeClaims and EBS volumes.
- Load balancers, target groups and security groups.
- Network interfaces created by EKS or ALB.
- WAF association if WAF was enabled.
- ECR images; dev is configured to remove them with the repository.

Capture anything that must be retained before proceeding.

## 4. Review and destroy Terraform resources

```bash
terraform -chdir=terraform/environments/dev plan -destroy
./scripts/99-destroy.sh
```

Review the destroy plan before confirming the script prompt.

## 5. Verify zero orphaned billable resources

Confirm in the target region that there are no project-tagged:

- EKS clusters or managed node groups;
- EC2 instances, EBS volumes or elastic network interfaces;
- NAT Gateways or Elastic IPs;
- ALBs or target groups;
- WAF Web ACLs;
- CloudWatch log groups retained unexpectedly.

Record the verification date and operator. State and plan files remain sensitive even after destruction.
