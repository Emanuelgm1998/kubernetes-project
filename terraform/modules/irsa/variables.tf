variable "project_name" {
  description = "Project name."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
}

variable "oidc_issuer_url" {
  description = "EKS OIDC issuer URL."
  type        = string
}

variable "oidc_provider_arn" {
  description = "Existing IAM OIDC provider ARN for the EKS cluster."
  type        = string
}

variable "common_tags" {
  description = "Common resource tags."
  type        = map(string)
  default     = {}
}

variable "external_secrets_resource_arns" {
  description = "Secrets Manager ARNs readable by External Secrets."
  type        = list(string)

  validation {
    condition     = length(var.external_secrets_resource_arns) > 0 && !contains(var.external_secrets_resource_arns, "*")
    error_message = "Provide at least one scoped Secrets Manager ARN; a global wildcard is forbidden."
  }
}
