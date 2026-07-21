module "vpc" {
  source = "../../modules/vpc"

  project_name             = var.project_name
  environment              = var.environment
  vpc_cidr                 = var.vpc_cidr
  availability_zones       = var.availability_zones
  public_subnets           = var.public_subnets
  private_subnets          = var.private_subnets
  enable_multi_nat_gateway = var.enable_multi_nat_gateway
  common_tags              = local.common_tags
}

module "ecr" {
  source = "../../modules/ecr"

  project_name = var.project_name
  environment  = var.environment
  common_tags  = local.common_tags
  force_delete = true
}

module "eks" {
  source = "../../modules/eks"

  project_name           = var.project_name
  environment            = var.environment
  cluster_version        = var.eks_cluster_version
  vpc_id                 = module.vpc.vpc_id
  private_subnet_ids     = module.vpc.private_subnet_ids
  allowed_api_cidrs      = var.allowed_api_cidrs
  endpoint_public_access = var.enable_eks_public_endpoint
  common_tags            = local.common_tags
}

module "irsa" {
  source = "../../modules/irsa"

  project_name                   = var.project_name
  environment                    = var.environment
  cluster_name                   = module.eks.cluster_name
  oidc_issuer_url                = module.eks.cluster_oidc_issuer_url
  aws_region                     = var.aws_region
  external_secrets_resource_arns = var.external_secrets_resource_arns
  common_tags                    = local.common_tags

  depends_on = [module.eks]
}

module "security" {
  source = "../../modules/security"

  project_name = var.project_name
  environment  = var.environment
  enabled      = var.enable_waf
  common_tags  = local.common_tags
}
