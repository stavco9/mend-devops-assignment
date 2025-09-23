locals {
  owner               = "stavco9@gmail.com"
  project             = "mend-devops"
  project_short       = replace(local.project, "-", "")
  environment         = "dev"
  resource_group_name = "mend-devops-dev-east-us-rg"
  region              = "East US"

  region_standard = lower(replace(local.region, " ", "-"))
  tenant_id       = data.azurerm_client_config.current.tenant_id
  tenant_prefix   = split("-", local.tenant_id)[0]

  remote_state_container_name       = "terraform-state"
  remote_state_region               = "West Europe"
  remote_state_resource_group_name  = "mend-devops-dev-west-europe-rg"
  remote_state_region_short         = join("", [for word in split(" ", lower(local.remote_state_region)) : substr(word, 0, 1)])
  remote_state_storage_account_name = substr(format("%s%s%s%s", local.project_short, local.environment, local.remote_state_region_short, local.tenant_prefix), 0, 24)
  remote_state_networking_key       = format("%s/%s/networking/terraform.tfstate", local.environment, local.region_standard)
  remote_state_dns_key              = format("%s/dns/terraform.tfstate", local.environment)
}

data "azurerm_client_config" "current" {}

data "terraform_remote_state" "networking" {
  backend = "azurerm"

  config = {
    use_cli              = true
    use_azuread_auth     = false
    tenant_id            = local.tenant_id
    resource_group_name  = local.remote_state_resource_group_name
    storage_account_name = local.remote_state_storage_account_name
    container_name       = local.remote_state_container_name
    key                  = local.remote_state_networking_key
  }
}

data "terraform_remote_state" "dns" {
  backend = "azurerm"

  config = {
    use_cli              = true
    use_azuread_auth     = false
    tenant_id            = local.tenant_id
    resource_group_name  = local.remote_state_resource_group_name
    storage_account_name = local.remote_state_storage_account_name
    container_name       = local.remote_state_container_name
    key                  = local.remote_state_dns_key
  }
}

module "aks" {
  source = "../../../../../../modules/azure/aks"

  # General settings
  project             = local.project
  owner               = local.owner
  environment         = local.environment
  region              = local.region
  resource_group_name = local.resource_group_name

  vnet_id           = data.terraform_remote_state.networking.outputs.vnet_id
  private_subnet_id = data.terraform_remote_state.networking.outputs.private_subnet_id
  public_subnet_id  = data.terraform_remote_state.networking.outputs.public_subnet_id

  # DNS settings
  dns_suffix                   = format("%s.%s", local.region_standard, data.terraform_remote_state.dns.outputs.dns_zone_name)
  dns_zone_id                  = data.terraform_remote_state.dns.outputs.dns_zone_id
  dns_zone_resource_group_name = data.terraform_remote_state.dns.outputs.dns_zone_resource_group_name

  # Kubernetes settings
  kubernetes_version = "1.33"

  # Nodes settings
  node_agent_size    = "Standard_DS2_v2"
  nodes_min_size     = 2
  nodes_max_size     = 2
  nodes_desired_size = 2

  # Add-ons settings
  enable_metrics_server                        = true
  metrics_server_version                       = "3.13.0"
  enable_azure_application_gateway_controller  = true
  azure_application_gateway_controller_version = "1.7.3"
  enable_cert_manager                          = true
  cert_manager_version                         = "v1.18.2"
  enable_external_dns                          = true
  external_dns_version                         = "1.19.0"
}