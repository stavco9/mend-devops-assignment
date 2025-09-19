# AWS Load Balancer Controller Certificate ACM

resource "aws_acm_certificate" "alb_controller_cert" {
  count = var.enable_aws_load_balancer_controller ? 1 : 0

  domain_name       = "*.${local.cluster_dns_suffix}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = local.tags
}

resource "aws_route53_record" "alb_controller_cert_validate" {
  for_each = var.enable_aws_load_balancer_controller ? {
    for dvo in aws_acm_certificate.alb_controller_cert[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.dns_zone_id
}

resource "aws_acm_certificate_validation" "alb_controller_cert_validate" {
  count = var.enable_aws_load_balancer_controller ? 1 : 0

  certificate_arn         = aws_acm_certificate.alb_controller_cert[0].arn
  validation_record_fqdns = [for record in aws_route53_record.alb_controller_cert_validate : record.fqdn]
}

# Metrics Server

resource "helm_release" "metrics_server" {
  count = var.enable_metrics_server ? 1 : 0

  name             = "metrics-server"
  repository       = "https://kubernetes-sigs.github.io/metrics-server/"
  chart            = "metrics-server"
  version          = var.metrics_server_version
  namespace        = "kube-system"
  create_namespace = false

  depends_on = [module.eks]
}

# AWS Load Balancer Controller Installation including Iam Role for Service Account

module "irsa_load_balancer_controller" {
  count = var.enable_aws_load_balancer_controller ? 1 : 0

  source                  = "./irsa"
  cluster_name            = local.cluster_name
  oidc_provider_name      = module.eks.oidc_provider
  oidc_provider_arn       = module.eks.oidc_provider_arn
  kubernetes_sa_namespace = "kube-system"
  kubernetes_sa_name      = "aws-load-balancer-controller"
  irsa_role_name          = "aws-load-balancer-controller"
  irsa_role_policies_arns = [var.aws_load_balancer_controller_policy_arn]

  tags = local.tags
}

resource "helm_release" "aws_load_balancer_controller" {
  count = var.enable_aws_load_balancer_controller ? 1 : 0

  name             = "aws-load-balancer-controller"
  repository       = "https://aws.github.io/eks-charts"
  chart            = "aws-load-balancer-controller"
  version          = var.aws_load_balancer_controller_version
  namespace        = "kube-system"
  create_namespace = false

  set = [{
    name  = "clusterName"
    value = local.cluster_name
    }, {
    name  = "region"
    value = data.aws_region.current.name
    }, {
    name  = "vpcId"
    value = var.vpc_id
    }, {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.irsa_load_balancer_controller[0].iam_role_arn
  }]

  depends_on = [module.eks]
}

# External DNS Installation including Iam Role for Service Account

module "irsa_external_dns" {
  count = var.enable_external_dns ? 1 : 0

  source                  = "./irsa"
  cluster_name            = local.cluster_name
  oidc_provider_name      = module.eks.oidc_provider
  oidc_provider_arn       = module.eks.oidc_provider_arn
  kubernetes_sa_namespace = "kube-system"
  kubernetes_sa_name      = "external-dns"
  irsa_role_name          = "external-dns"
  irsa_role_policies_arns = [var.external_dns_policy_arn]

  tags = local.tags
}

resource "helm_release" "external_dns" {
  count = var.enable_external_dns ? 1 : 0

  name             = "external-dns"
  repository       = "https://kubernetes-sigs.github.io/external-dns/"
  chart            = "external-dns"
  version          = var.external_dns_version
  namespace        = "kube-system"
  create_namespace = false

  set = [{
    name  = "provider.name"
    value = "aws"
    }, {
    name  = "env[0].name"
    value = "AWS_DEFAULT_REGION"
    }, {
    name  = "env[0].value"
    value = data.aws_region.current.name
    }, {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.irsa_external_dns[0].iam_role_arn
  }]

  depends_on = [module.eks]
}
