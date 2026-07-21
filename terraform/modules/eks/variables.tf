variable "project_name" {
  description = "Project name."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "cluster_version" {
  description = "EKS Kubernetes version."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for EKS and node groups."
  type        = list(string)
}

variable "allowed_api_cidrs" {
  description = "CIDR blocks allowed to reach the EKS API endpoint."
  type        = list(string)
  default     = []
}

variable "endpoint_public_access" {
  description = "Enable the EKS public API endpoint."
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
