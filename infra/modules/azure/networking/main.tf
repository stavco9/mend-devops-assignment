locals {
  tags = {
    Environment = var.environment
    Region      = var.region
    Project     = var.project
    Owner       = var.owner
    ManagedBy   = "terraform"
  }

  vnet_name = format("vnet-%s-%s", var.project, var.environment)
}

resource "azurerm_virtual_network" "vnet" {
  address_space       = [var.vnet_cidr]
  location            = var.region
  name                = local.vnet_name
  resource_group_name = var.resource_group_name
  tags                = local.tags
}

resource "azurerm_subnet" "vnet_private_subnet" {
  address_prefixes                  = [var.vnet_private_subnet_cidr]
  name                              = "${local.vnet_name}-private-sn"
  resource_group_name               = var.resource_group_name
  virtual_network_name              = azurerm_virtual_network.vnet.name
  private_endpoint_network_policies = "Enabled"
  default_outbound_access_enabled   = false
}

resource "azurerm_subnet" "vnet_public_subnet" {
  address_prefixes                  = [var.vnet_public_subnet_cidr]
  name                              = "${local.vnet_name}-public-sn"
  resource_group_name               = var.resource_group_name
  virtual_network_name              = azurerm_virtual_network.vnet.name
  private_endpoint_network_policies = "Enabled"
  default_outbound_access_enabled   = true
}

resource "azurerm_public_ip" "vnet_public_ip" {
  count = var.enable_nat_gateway ? 1 : 0

  name                = "${local.vnet_name}-public-ip"
  location            = var.region
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = local.tags
}

resource "azurerm_nat_gateway" "vnet_nat_gateway" {
  count = var.enable_nat_gateway ? 1 : 0

  name                = "${local.vnet_name}-nat-gateway"
  location            = var.region
  resource_group_name = var.resource_group_name
  sku_name            = "Standard"

  tags = local.tags
}

resource "azurerm_nat_gateway_public_ip_association" "vnet_nat_gateway_public_ip_association" {
  count = var.enable_nat_gateway ? 1 : 0

  nat_gateway_id       = one(azurerm_nat_gateway.vnet_nat_gateway[*].id)
  public_ip_address_id = one(azurerm_public_ip.vnet_public_ip[*].id)
}

resource "azurerm_subnet_nat_gateway_association" "vnet_nat_gateway_association" {
  count = var.enable_nat_gateway ? 1 : 0

  subnet_id      = one(azurerm_subnet.vnet_private_subnet[*].id)
  nat_gateway_id = one(azurerm_nat_gateway.vnet_nat_gateway[*].id)
}