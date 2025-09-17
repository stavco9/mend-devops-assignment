locals {
  tags = {
    Environment = "dev"
    Region      = data.aws_region.current.region
    Project     = "mend-devops"
    Owner       = "stavco9@gmail.com"
    ManagedBy   = "terraform"
  }

  root_zone = "stavco9.com"
  dns_zone  = "dev.aws.mend-devops.stavco9.com"
}

data "aws_region" "current" {
  provider = aws.mend-devops
}

data "aws_route53_zone" "stav_devops_delegation" {
  provider = aws.stav-devops

  name = local.root_zone
}

resource "aws_route53_zone" "mend_devops" {
  provider = aws.mend-devops

  name = local.dns_zone
  tags = local.tags
}

resource "aws_route53_record" "stav_devops_delegation" {
  provider = aws.stav-devops

  zone_id = data.aws_route53_zone.stav_devops_delegation.zone_id

  name    = local.dns_zone
  type    = "NS"
  ttl     = 300
  records = aws_route53_zone.mend_devops.name_servers
}