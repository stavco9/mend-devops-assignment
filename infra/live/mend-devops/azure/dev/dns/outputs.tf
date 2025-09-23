output "dns_zone_name" {
  value = azurerm_dns_zone.mend_devops.name
}

output "dns_zone_id" {
  value = azurerm_dns_zone.mend_devops.id
}

output "dns_zone_resource_group_name" {
  value = azurerm_dns_zone.mend_devops.resource_group_name
}