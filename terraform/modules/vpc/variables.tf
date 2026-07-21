variable "project_name" {
  description = "Project name."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "availability_zones" {
  description = "Availability zones."
  type        = list(string)
}

variable "public_subnets" {
  description = "Public subnet CIDRs."
  type        = list(string)
}

variable "private_subnets" {
  description = "Private subnet CIDRs."
  type        = list(string)
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC."
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC."
  type        = bool
  default     = true
}

variable "enable_multi_nat_gateway" {
  description = "Create one NAT Gateway per public subnet if true. Create one NAT Gateway if false."
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Common resource tags."
  type        = map(string)
  default     = {}
}
