locals {
  appgw_pip_name                 = "${local.cluster_name}-appgw-pip"
  appgw_name                     = "${local.cluster_name}-ingress-appgw"
  backend_address_pool_name      = "${local.cluster_name}-beap"
  frontend_ip_configuration_name = "${local.cluster_name}-feip"
  frontend_port_name             = "${local.cluster_name}-feport"
  http_setting_name              = "${local.cluster_name}-be-htst"
  listener_name                  = "${local.cluster_name}-httplstn"
  request_routing_rule_name      = "${local.cluster_name}-rqrt"
}

resource "azurerm_public_ip" "appgw_ingress_pip" {
  count = var.enable_azure_application_gateway_controller ? 1 : 0

  allocation_method   = "Static"
  location            = local.region
  name                = local.appgw_pip_name
  resource_group_name = local.resource_group_name
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "appgw_ingress" {
  count = var.enable_azure_application_gateway_controller ? 1 : 0

  location            = local.region
  name                = local.appgw_name
  resource_group_name = local.resource_group_name

  backend_address_pool {
    name = local.backend_address_pool_name
  }
  backend_http_settings {
    cookie_based_affinity = "Disabled"
    name                  = local.http_setting_name
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
  }
  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.appgw_ingress_pip[0].id
  }
  frontend_port {
    name = local.frontend_port_name
    port = 80
  }
  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = var.public_subnet_id
  }
  http_listener {
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    name                           = local.listener_name
    protocol                       = "Http"
  }
  request_routing_rule {
    http_listener_name         = local.listener_name
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
    priority                   = 1
  }
  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  lifecycle {
    ignore_changes = [
      tags,
      backend_address_pool,
      frontend_port,
      redirect_configuration,
      ssl_certificate,
      backend_http_settings,
      http_listener,
      probe,
      request_routing_rule,
      url_path_map,
      zones,
    ]
  }

  tags = local.tags
}