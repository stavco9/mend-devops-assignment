variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "owner" {
  type = string
}

variable "region" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "vnet_id" {
  type = string
}

variable "dns_suffix" {
  type = string
}

variable "dns_zone_id" {
  type = string
}

variable "dns_zone_resource_group_name" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "private_subnet_id" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "node_agent_size" {
  type    = string
  default = "Standard_DS2_v2"
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

variable "nodes_os_disk_size_gb" {
  type    = number
  default = 60
}

variable "enable_metrics_server" {
  type    = bool
  default = true
}

variable "metrics_server_version" {
  type    = string
  default = "3.13.0"
}

variable "enable_azure_application_gateway_controller" {
  type    = bool
  default = true
}

variable "azure_application_gateway_controller_version" {
  type    = string
  default = "1.7.3"
}

variable "enable_cert_manager" {
  type    = bool
  default = true
}

variable "cert_manager_version" {
  type    = string
  default = "v1.18.2"
}

variable "enable_external_dns" {
  type    = bool
  default = true
}

variable "external_dns_version" {
  type    = string
  default = "1.19.0"
}