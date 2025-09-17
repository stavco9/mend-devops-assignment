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