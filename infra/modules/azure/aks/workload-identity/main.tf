locals {
  workload_identity_name = "workload-id-${var.cluster_name}-${var.workload_identity_name}"
}

resource "azurerm_user_assigned_identity" "workload_identity" {
  name                = local.workload_identity_name
  resource_group_name = var.resource_group_name
  location            = var.region

  tags = var.tags
}

resource "azurerm_federated_identity_credential" "workload_identity" {
  name                = local.workload_identity_name
  resource_group_name = var.resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.oidc_provider_url
  parent_id           = azurerm_user_assigned_identity.workload_identity.id
  subject             = "system:serviceaccount:${var.kubernetes_sa_namespace}:${var.kubernetes_sa_name}"
}

resource "azurerm_role_assignment" "workload_identity_role_assignment" {
  count = length(var.workload_identity_roles)

  principal_id         = azurerm_user_assigned_identity.workload_identity.principal_id
  scope                = var.workload_identity_scopes[count.index]
  role_definition_name = var.workload_identity_roles[count.index]
}