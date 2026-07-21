output "oidc_provider_arn" {
  description = "EKS OIDC provider ARN."
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "aws_load_balancer_controller_role_arn" {
  description = "IAM role ARN for AWS Load Balancer Controller."
  value       = aws_iam_role.load_balancer_controller.arn
}

output "external_secrets_role_arn" {
  description = "IAM role ARN for External Secrets Operator."
  value       = aws_iam_role.external_secrets.arn
}

output "ebs_csi_role_arn" {
  description = "IAM role ARN for the EBS CSI controller."
  value       = aws_iam_role.ebs_csi.arn
}
