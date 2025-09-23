locals {
  tags = {
    Environment = var.environment
    Region      = var.region
    Project     = var.project
    Owner       = var.owner
    ManagedBy   = "terraform"
    AKS_Cluster = local.cluster_name
  }

  region              = var.region
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  cluster_name       = format("k8s-%s-%s", var.project, var.environment)
  cluster_dns_suffix = format("k8s.%s", var.dns_suffix)
}

data "azurerm_resource_group" "current" {
  name = var.resource_group_name
}
data "azurerm_resource_group" "dns_zone" {
  name = var.dns_zone_resource_group_name
}
data "azurerm_client_config" "current" {}
data "azurerm_location" "current" {
  location = local.region
}

module "aks" {
  #checkov:skip=CKV_AZURE_141:We enable admin account here so we can provision K8s resources directly in this simple example
  source  = "Azure/aks/azurerm"
  version = "11.0.0"

  prefix                    = local.cluster_name
  resource_group_name       = local.resource_group_name
  location                  = local.region
  kubernetes_version        = var.kubernetes_version
  automatic_channel_upgrade = "patch"
  agents_count              = null
  agents_max_count          = var.nodes_max_size
  agents_min_count          = var.nodes_min_size
  agents_pool_name          = "nodegeneral"
  agents_size               = var.node_agent_size
  agents_type               = "VirtualMachineScaleSets"
  agents_pool_linux_os_configs = [
    {
      transparent_huge_page_enabled = "always"
      sysctl_configs = [
        {
          fs_aio_max_nr               = 65536
          fs_file_max                 = 100000
          fs_inotify_max_user_watches = 1000000
        }
      ]
    }
  ]
  azure_policy_enabled                 = true
  auto_scaling_enabled                 = true
  host_encryption_enabled              = true
  local_account_disabled               = false
  log_analytics_workspace_enabled      = true
  cluster_log_analytics_workspace_name = "${local.cluster_name}-log-analytics"
  network_plugin                       = "azure"
  network_policy                       = "azure"
  os_disk_size_gb                      = var.nodes_os_disk_size_gb
  private_cluster_enabled              = false
  role_based_access_control_enabled    = true
  rbac_aad_azure_rbac_enabled          = true
  rbac_aad_admin_group_object_ids      = [data.azurerm_client_config.current.object_id]
  rbac_aad_tenant_id                   = data.azurerm_client_config.current.tenant_id
  oidc_issuer_enabled                  = true
  workload_identity_enabled            = true
  sku_tier                             = "Standard"
  net_profile_dns_service_ip           = "172.16.0.10"
  net_profile_service_cidr             = "172.16.0.0/24"
  vnet_subnet = {
    id = var.private_subnet_id
  }

  tags = local.tags
}

resource "azurerm_role_assignment" "aks_admin" {
  principal_id         = data.azurerm_client_config.current.object_id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  scope                = module.aks.aks_id
}