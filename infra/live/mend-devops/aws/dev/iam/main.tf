locals {
  tags = {
    Environment = "dev"
    Region      = data.aws_region.current.region
    Project     = "mend-devops"
    Owner       = "stavco9@gmail.com"
    ManagedBy   = "terraform"
  }

  ssm_policy = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_region" "current" {}

resource "aws_iam_policy" "load_balancer_controller_policy" {
  name_prefix = "AWSLoadBalancerControllerIAMPolicy"
  policy      = file("./aws-load-balancer-permissions.json")

  tags = local.tags
}

resource "aws_iam_policy" "external_dns_policy" {
  name_prefix = "AllowExternalDNSUpdates"
  policy      = file("./route53-permissions.json")

  tags = local.tags
}