locals {
  project     = "mend-devops"
  environment = "dev"
  region      = "West Europe"

  tags = {
    Environment = local.environment
    Region      = local.region
    Project     = local.project
    Owner       = "stavco9@gmail.com"
    ManagedBy   = "terraform"
  }

  resource_group_name = format("%s-%s-%s-rg", local.project, local.environment, lower(replace(local.region, " ", "-")))

  root_zone = "stavco9.com"
  dns_zone  = "dev.azure.mend-devops.stavco9.com"
}

data "aws_route53_zone" "stav_devops_delegation" {
  name = local.root_zone
}

resource "azurerm_dns_zone" "mend_devops" {
  name                = local.dns_zone
  resource_group_name = local.resource_group_name
  tags                = local.tags
}

resource "aws_route53_record" "stav_devops_delegation" {
  zone_id = data.aws_route53_zone.stav_devops_delegation.zone_id

  name    = local.dns_zone
  type    = "NS"
  ttl     = 300
  records = azurerm_dns_zone.mend_devops.name_servers
}