module "networking" {
  source = "../../../../../../modules/azure/networking"

  resource_group_name = "mend-devops-dev-west-europe-rg"
  region              = "West Europe"
  project             = "mend-devops"
  owner               = "stavco9@gmail.com"
  environment         = "dev"

  vnet_cidr                = "10.0.6.0/23"
  vnet_private_subnet_cidr = "10.0.6.0/24"
  vnet_public_subnet_cidr  = "10.0.7.0/24"

  enable_nat_gateway                   = true
}