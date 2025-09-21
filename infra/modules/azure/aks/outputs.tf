output "cluster_endpoint" {
  value = module.aks.host
}

output "oidc_provider" {
  value = module.aks.oidc_issuer_url
}

output "cluster_name" {
  value = module.aks.aks_name
}

output "cluster_id" {
  value = module.aks.aks_id
}

output "client_certificate" {
  value = module.aks.client_certificate
}

output "client_key" {
  value = module.aks.client_key
}

output "cluster_ca_certificate" {
  value = module.aks.cluster_ca_certificate
}

output "cluster_dns_suffix" {
  value = local.cluster_dns_suffix
}