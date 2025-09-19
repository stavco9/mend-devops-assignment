terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    use_cli              = true
    use_azuread_auth     = false
    tenant_id            = "5f9ccf0b-2066-472e-993a-438adb2f77e0"
    resource_group_name  = "mend-devops-dev-west-europe-rg"
    storage_account_name = "menddevopsdevwe5f9ccf0b"
    container_name       = "terraform-state"
    key                  = "dev/dns/terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  tenant_id = "5f9ccf0b-2066-472e-993a-438adb2f77e0"
}

provider "aws" {
  profile = "stav-devops"
  region  = "us-east-1"
}