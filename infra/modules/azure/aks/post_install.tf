resource "helm_release" "cert_manager" {
  count = var.enable_cert_manager ? 1 : 0

  name       = "cert-manager"
  repository = "oci://quay.io/jetstack/charts"
  chart      = "cert-manager"
  version    = var.cert_manager_version

  namespace        = "cert-manager"
  create_namespace = true

  set = [{
    name  = "crds.enabled"
    value = true
  }]

  depends_on = [module.aks]
}

resource "helm_release" "cluster_issuer" {
  count = var.enable_cert_manager ? 1 : 0

  name       = "cert-manager-issuers"
  repository = "https://charts.adfinis.com"
  chart      = "cert-manager-issuers"
  version    = "0.3.0"

  namespace        = "cert-manager"
  create_namespace = false

  values = [file("${path.module}/cluster-issuer.yaml")]

  depends_on = [helm_release.cert_manager]
}

module "appgw_ingress_workload_identity" {
  count = var.enable_azure_application_gateway_controller ? 1 : 0

  source = "./workload-identity"

  resource_group_name     = local.resource_group_name
  region                  = local.region
  cluster_name            = local.cluster_name
  oidc_provider_url       = module.aks.oidc_issuer_url
  workload_identity_name  = "appgw-ingress-controller"
  kubernetes_sa_namespace = "kube-system"
  kubernetes_sa_name      = "ingress-azure"

  workload_identity_scopes = [
    data.azurerm_resource_group.current.id,
    module.aks.node_resource_group_id,
    azurerm_application_gateway.appgw_ingress[0].id,
    var.vnet_id
  ]
  workload_identity_roles = ["Reader", "Contributor", "Contributor", "Contributor"]
  tags                    = local.tags
}

resource "helm_release" "azure_application_gateway_controller" {
  count = var.enable_azure_application_gateway_controller ? 1 : 0

  name       = "ingress-azure"
  repository = "oci://mcr.microsoft.com/azure-application-gateway/charts"
  chart      = "ingress-azure"
  version    = var.azure_application_gateway_controller_version

  namespace        = "kube-system"
  create_namespace = false

  set = [{
    name  = "appgw.applicationGatewayID"
    value = azurerm_application_gateway.appgw_ingress[0].id
    }, {
    name  = "armAuth.type",
    value = "workloadIdentity"
    }, {
    name  = "armAuth.identityClientID",
    value = module.appgw_ingress_workload_identity[0].workload_identity_client_id
    }, {
    name  = "rbac.enabled",
    value = true
  }]

  depends_on = [module.aks]
}

module "external_dns_workload_identity" {
  count = var.enable_external_dns ? 1 : 0

  source = "./workload-identity"

  resource_group_name     = local.resource_group_name
  region                  = local.region
  cluster_name            = local.cluster_name
  oidc_provider_url       = module.aks.oidc_issuer_url
  workload_identity_name  = "external-dns"
  kubernetes_sa_namespace = "kube-system"
  kubernetes_sa_name      = "external-dns"

  workload_identity_scopes = [
    data.azurerm_resource_group.current.id,
    var.dns_zone_id
  ]
  workload_identity_roles = ["Reader", "DNS Zone Contributor"]
  tags                    = local.tags
}

resource "kubernetes_secret" "external_dns" {
  metadata {
    name      = "external-dns-azure"
    namespace = "kube-system"
  }

  data = {
    "azure.json" = jsonencode({
      tenantId                     = data.azurerm_client_config.current.tenant_id
      subscriptionId               = data.azurerm_client_config.current.subscription_id
      resourceGroup                = local.resource_group_name
      useWorkloadIdentityExtension = true
    })
  }

  type = "Opaque"

  depends_on = [module.aks]
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
    value = "azure"
    }, {
    name  = "fullnameOverride"
    value = "external-dns"
    }, {
    name  = "podLabels.azure\\.workload\\.identity/use"
    value = "true"
    type  = "string"
    }, {
    name  = "serviceAccount.labels.azure\\.workload\\.identity/use"
    value = "true"
    type  = "string"
    }, {
    name  = "serviceAccount.annotations.azure\\.workload\\.identity/client-id"
    value = module.external_dns_workload_identity[0].workload_identity_client_id
    }, {
    name  = "extraVolumes[0].name"
    value = "azure-config-file"
    }, {
    name  = "extraVolumes[0].secret.secretName"
    value = "external-dns-azure"
    }, {
    name  = "extraVolumeMounts[0].name"
    value = "azure-config-file"
    }, {
    name  = "extraVolumeMounts[0].mountPath"
    value = "/etc/kubernetes"
    }, {
    name  = "extraVolumeMounts[0].readOnly"
    value = true
  }]

  depends_on = [module.aks, kubernetes_secret.external_dns]
}
