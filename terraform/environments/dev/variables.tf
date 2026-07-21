variable "aws_region" {
  description = "AWS region used for the development environment."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
  default     = "kubernetes-platform"
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
  default     = "10.40.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones for the VPC."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least two availability zones are required."
  }
}

variable "public_subnets" {
  description = "Public subnet CIDR blocks."
  type        = list(string)
  default     = ["10.40.1.0/24", "10.40.2.0/24"]
}

variable "private_subnets" {
  description = "Private subnet CIDR blocks. Larger ranges are useful for EKS pods using AWS VPC CNI."
  type        = list(string)
  default     = ["10.40.16.0/22", "10.40.20.0/22"]
}

variable "eks_cluster_version" {
  description = "Amazon EKS Kubernetes version."
  type        = string
  default     = "1.35"
}

variable "cluster_admin_principal_arn" {
  description = "IAM Identity Center role ARN or IAM role ARN granted EKS cluster-admin access."
  type        = string

  validation {
    condition     = can(regex("^arn:aws[a-z-]*:iam::[0-9]{12}:role/.+", var.cluster_admin_principal_arn))
    error_message = "cluster_admin_principal_arn must be an IAM role ARN."
  }
}

variable "enable_multi_nat_gateway" {
  description = "If true, creates one NAT Gateway per public subnet. If false, creates a single NAT Gateway to reduce costs."
  type        = bool
  default     = false
}

variable "allowed_api_cidrs" {
  description = "CIDR blocks allowed to reach the EKS public API endpoint. Use your public IP/32 for stricter access."
  type        = list(string)
  default     = []

  validation {
    condition     = !contains(var.allowed_api_cidrs, "0.0.0.0/0")
    error_message = "The EKS API must not be exposed to 0.0.0.0/0. Use explicit trusted /32 CIDRs."
  }
}

variable "enable_eks_public_endpoint" {
  description = "Expose the EKS API publicly to allowed_api_cidrs. Keep false unless operator access is required."
  type        = bool
  default     = false
}

variable "enable_waf" {
  description = "Create the regional WAF Web ACL. Disabled by default to control portfolio costs."
  type        = bool
  default     = false
}
