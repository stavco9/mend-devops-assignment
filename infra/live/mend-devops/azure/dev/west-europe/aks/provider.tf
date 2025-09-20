terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }
  }

  backend "azurerm" {
    use_cli              = true
    use_azuread_auth     = false
    tenant_id            = "5f9ccf0b-2066-472e-993a-438adb2f77e0"
    resource_group_name  = "mend-devops-dev-west-europe-rg"
    storage_account_name = "menddevopsdevwe5f9ccf0b"
    container_name       = "terraform-state"
    key                  = "dev/west-europe/aks/terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = "2bcfe589-26cd-455a-bdd4-b8975088c52f"
  tenant_id       = "5f9ccf0b-2066-472e-993a-438adb2f77e0"
}

provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    client_certificate     = base64decode(module.aks.client_certificate)
    client_key             = base64decode(module.aks.client_key)
    cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)
  }
}