variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "owner" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "region" {
  type = string
}

variable "vnet_cidr" {
  type = string
}

variable "vnet_private_subnet_cidr" {
  type = string
}

variable "vnet_public_subnet_cidr" {
  type = string
}

variable "enable_nat_gateway" {
  type    = bool
  default = true
}