output "vpc_id" {
  description = "VPC ID."
  value       = module.vpc.vpc_id
}

output "aws_region" {
  description = "AWS region used by the environment."
  value       = var.aws_region
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs."
  value       = module.vpc.private_subnet_ids
}

output "ecr_repository_url" {
  description = "ECR repository URL."
  value       = module.ecr.repository_url
}

output "eks_cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint."
  value       = module.eks.cluster_endpoint
}

output "load_balancer_controller_role_arn" {
  description = "IAM role ARN for AWS Load Balancer Controller."
  value       = module.irsa.aws_load_balancer_controller_role_arn
}

output "external_secrets_role_arn" {
  description = "IAM role ARN for External Secrets Operator."
  value       = module.irsa.external_secrets_role_arn
}

output "waf_web_acl_arn" {
  description = "WAF Web ACL ARN."
  value       = module.security.web_acl_arn
}

output "ebs_csi_role_arn" {
  description = "IAM role ARN for the EBS CSI controller."
  value       = module.irsa.ebs_csi_role_arn
}

output "vpc_cni_role_arn" {
  description = "IAM role ARN for the VPC CNI add-on."
  value       = module.eks.vpc_cni_role_arn
}
