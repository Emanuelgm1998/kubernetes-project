# Architecture Overview

This project implements a secure Kubernetes platform on AWS.

## Main components

- Multi-AZ VPC.
- Public subnets for load balancers and NAT Gateways.
- Private subnets for EKS worker nodes.
- Amazon EKS managed control plane.
- Managed node groups for system and application workloads.
- Amazon ECR for container images.
- IAM roles and IRSA for pod-level AWS permissions.
- AWS Load Balancer Controller for ALB provisioning.
- ArgoCD for GitOps.
- CloudWatch for control plane logs.
- Optional Prometheus and Grafana for Kubernetes observability.

## Deployment model

The infrastructure is intended to be deployed temporarily for validation and portfolio evidence. After validation, run `terraform destroy` to avoid ongoing AWS charges.

## Networking model

- Public subnets route to Internet Gateway.
- Private subnets route to NAT Gateway.
- EKS nodes run in private subnets.
- ALB is created by AWS Load Balancer Controller from Kubernetes Ingress.
