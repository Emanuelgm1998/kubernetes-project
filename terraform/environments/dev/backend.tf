# Local backend by default for portfolio simplicity.
# For a production-style remote backend, uncomment and configure:
#
# terraform {
#   backend "s3" {
#     bucket       = "your-terraform-state-bucket"
#     key          = "kubernetes-platform/dev/terraform.tfstate"
#     region       = "us-east-1"
#     encrypt      = true
#     use_lockfile = true
#   }
# }
