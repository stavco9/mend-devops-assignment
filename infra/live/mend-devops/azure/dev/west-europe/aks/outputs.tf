output "cluster_endpoint" {
  value = module.aks.cluster_endpoint

  sensitive = true
}

output "oidc_provider" {
  value = module.aks.oidc_provider
}

output "cluster_name" {
  value = module.aks.cluster_name
}

output "client_certificate" {
  value = module.aks.client_certificate

  sensitive = true
}

output "client_key" {
  value = module.aks.client_key

  sensitive = true
}

output "cluster_ca_certificate" {
  value = module.aks.cluster_ca_certificate

  sensitive = true
}

output "cluster_dns_suffix" {
  value = module.aks.cluster_dns_suffix
}