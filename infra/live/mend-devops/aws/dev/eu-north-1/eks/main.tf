locals {
  owner                       = "stavco9@gmail.com"
  project                     = "mend-devops"
  environment                 = "dev"
  aws_profile                 = "mend-devops"
  aws_region                  = data.aws_region.current_region.name
  aws_account_id              = data.aws_caller_identity.current_account_id.account_id
  remote_state_dynamodb_table = "terraform-state-lock"
  remote_state_bucket         = format("%s-%s-terraform-state", local.aws_account_id, local.aws_region)
  remote_state_region         = "eu-north-1"
  remote_state_networking_key = format("%s/%s/networking/terraform.tfstate", local.environment, local.aws_region)
  remote_state_iam_key        = format("%s/iam/terraform.tfstate", local.environment)
  remote_state_route53_key    = format("%s/route53/terraform.tfstate", local.environment)
}

data "aws_region" "current_region" {}
data "aws_caller_identity" "current_account_id" {}

data "terraform_remote_state" "networking" {
  backend = "s3"

  config = {
    bucket         = local.remote_state_bucket
    key            = local.remote_state_networking_key
    dynamodb_table = local.remote_state_dynamodb_table
    profile        = local.aws_profile
    region         = local.remote_state_region
  }
}

data "terraform_remote_state" "route53" {
  backend = "s3"

  config = {
    bucket         = local.remote_state_bucket
    key            = local.remote_state_route53_key
    dynamodb_table = local.remote_state_dynamodb_table
    profile        = local.aws_profile
    region         = local.remote_state_region
  }
}

module "eks" {
  source = "../../../../../../modules/aws/eks"

  project                = local.project
  owner                  = local.owner
  environment            = local.environment
  vpc_id                 = data.terraform_remote_state.networking.outputs.vpc_id
  dns_suffix             = format("%s.%s", local.aws_region, data.terraform_remote_state.route53.outputs.dns_zone_name)
  kubernetes_version     = "1.33"
  private_subnets_ids    = data.terraform_remote_state.networking.outputs.private_subnet_ids
  nodes_instance_types   = ["t3.medium"]
  nodes_min_size         = 2
  nodes_max_size         = 2
  nodes_desired_size     = 2
  enable_metrics_server  = true
  metrics_server_version = "3.13.0"
}