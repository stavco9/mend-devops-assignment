terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    use_cli              = true
    use_azuread_auth     = false
    tenant_id            = "5f9ccf0b-2066-472e-993a-438adb2f77e0"
    resource_group_name  = "mend-devops-dev-west-europe-rg"
    storage_account_name = "menddevopsdevwe5f9ccf0b"
    container_name       = "terraform-state"
    key                  = "dev/east-us/networking/terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = "2bcfe589-26cd-455a-bdd4-b8975088c52f"
  tenant_id       = "5f9ccf0b-2066-472e-993a-438adb2f77e0"
}