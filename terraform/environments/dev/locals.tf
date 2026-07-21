locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = "Emanuel Gonzalez"
    Purpose     = "Portfolio"
  }

  name_prefix = "${var.project_name}-${var.environment}"
}
