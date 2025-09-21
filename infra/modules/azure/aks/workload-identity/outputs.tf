output "workload_identity_name" {
  value = azurerm_user_assigned_identity.workload_identity.name
}

output "workload_identity_client_id" {
  value = azurerm_user_assigned_identity.workload_identity.client_id
}