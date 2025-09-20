output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}

output "public_subnet_id" {
  value = azurerm_subnet.vnet_public_subnet.id
}

output "public_subnet_name" {
  value = azurerm_subnet.vnet_public_subnet.name
}

output "private_subnet_id" {
  value = azurerm_subnet.vnet_private_subnet.id
}

output "private_subnet_name" {
  value = azurerm_subnet.vnet_private_subnet.name
}