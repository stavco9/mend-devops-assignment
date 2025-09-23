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
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
  }

  backend "azurerm" {
    use_cli              = true
    use_azuread_auth     = false
    tenant_id            = "5f9ccf0b-2066-472e-993a-438adb2f77e0"
    resource_group_name  = "mend-devops-dev-west-europe-rg"
    storage_account_name = "menddevopsdevwe5f9ccf0b"
    container_name       = "terraform-state"
    key                  = "dev/east-us/aks/terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = "2bcfe589-26cd-455a-bdd4-b8975088c52f"
  tenant_id       = "5f9ccf0b-2066-472e-993a-438adb2f77e0"
}

provider "helm" {
  kubernetes = {
    host                   = module.aks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["get-token", "--login", "azurecli", "--server-id", "6dae42f8-4368-4678-94ff-3960e28e3630"]
      command     = "kubelogin"
    }
  }
}

provider "kubernetes" {
  host                   = module.aks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["get-token", "--login", "azurecli", "--server-id", "6dae42f8-4368-4678-94ff-3960e28e3630"]
    command     = "kubelogin"
  }
}