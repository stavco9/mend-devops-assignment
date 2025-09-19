variable "cluster_name" {
  type = string
}

variable "oidc_provider_name" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "kubernetes_sa_namespace" {
  type = string
  default = "default"
}

variable "kubernetes_sa_name" {
  type = string
  default = "default"
}

variable "irsa_role_name" {
  type = string
}

variable "irsa_role_policies_arns" {
  type = list(string)
  default = []
}

variable "tags" {
  type = map(string)
  default = {}
}