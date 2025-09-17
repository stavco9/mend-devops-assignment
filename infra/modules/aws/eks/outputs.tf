output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "oidc_provider" {
  value = module.eks.oidc_provider
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "cluster_dns_suffix" {
  value = local.cluster_dns_suffix
}