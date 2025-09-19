variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "owner" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "dns_suffix" {
  type = string
}

variable "dns_zone_id" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "private_subnets_ids" {
  type = list(string)
}

variable "nodes_instance_types" {
  type = list(string)
}

variable "nodes_min_size" {
  type    = number
  default = 1
}

variable "nodes_max_size" {
  type    = number
  default = 1
}

variable "nodes_desired_size" {
  type    = number
  default = 1
}

variable "enable_metrics_server" {
  type    = bool
  default = true
}

variable "metrics_server_version" {
  type    = string
  default = "3.13.0"
}

variable "enable_aws_load_balancer_controller" {
  type    = bool
  default = true
}

variable "aws_load_balancer_controller_policy_arn" {
  type    = string
  default = ""
}

variable "aws_load_balancer_controller_version" {
  type    = string
  default = "1.13.4"
}

variable "enable_external_dns" {
  type    = bool
  default = true
}

variable "external_dns_policy_arn" {
  type    = string
  default = ""
}

variable "external_dns_version" {
  type    = string
  default = "1.19.0"
}

variable "enable_eks_pod_identity_webhook" {
  type    = bool
  default = true
}

variable "eks_pod_identity_webhook_version" {
  type    = string
  default = "2.5.2"
}

variable "enable_cert_manager" {
  type    = bool
  default = true
}

variable "cert_manager_version" {
  type    = string
  default = "v1.18.2"
}