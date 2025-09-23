terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }
  }

  backend "s3" {
    bucket         = "739929374881-eu-north-1-terraform-state"
    key            = "dev/us-east-1/eks/terraform.tfstate"
    dynamodb_table = "terraform-state-lock"
    profile        = "mend-devops"
    region         = "eu-north-1"
  }
}

# Configure the AWS Provider
provider "aws" {
  profile = "mend-devops"
  region  = "us-east-1"
}

provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", "us-east-1", "--profile", "mend-devops"]
      command     = "aws"
    }
  }
}