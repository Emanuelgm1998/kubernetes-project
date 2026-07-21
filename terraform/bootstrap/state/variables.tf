variable "aws_region" {
  description = "AWS region for the Terraform state bucket."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used in the globally unique bucket name."
  type        = string
  default     = "kubernetes-platform"
}

variable "state_retention_days" {
  description = "Days to retain noncurrent state object versions."
  type        = number
  default     = 90

  validation {
    condition     = var.state_retention_days >= 30
    error_message = "Retain noncurrent state versions for at least 30 days."
  }
}
