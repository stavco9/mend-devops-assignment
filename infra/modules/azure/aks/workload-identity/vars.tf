variable "region" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "oidc_provider_url" {
  type = string
}

variable "kubernetes_sa_namespace" {
  type    = string
  default = "default"
}

variable "kubernetes_sa_name" {
  type    = string
  default = "default"
}

variable "workload_identity_name" {
  type = string
}

variable "workload_identity_scopes" {
  type    = list(string)
  default = []
}

variable "workload_identity_roles" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}