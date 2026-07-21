# Interview Talking Points

## How to explain this project

This project is a reproducible AWS EKS platform built with Terraform and GitOps principles.

## Strong points

- Modular Infrastructure as Code.
- Multi-AZ network design.
- Private worker nodes.
- IAM least privilege and IRSA.
- ECR for container image management.
- AWS Load Balancer Controller for Kubernetes-native ALB provisioning.
- ArgoCD for GitOps.
- Security controls such as WAF, RBAC and Network Policies.
- Cost-aware deployment and destroy workflow.

## Why EKS?

EKS provides a managed Kubernetes control plane while allowing integration with AWS IAM, VPC networking, ECR, ALB and CloudWatch.

## Why IRSA?

IRSA allows assigning IAM permissions at service account level instead of giving broad permissions to worker nodes.

## Why private subnets?

Worker nodes do not need direct exposure to the internet. They can pull images and reach AWS APIs through controlled outbound paths.

## Why destroy after validation?

The project is a portfolio artifact. Keeping infrastructure running continuously would generate unnecessary costs. The value is in reproducible code, evidence and architecture.
