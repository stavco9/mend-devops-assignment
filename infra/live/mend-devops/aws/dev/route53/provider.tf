terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket         = "739929374881-eu-north-1-terraform-state"
    key            = "dev/route53/terraform.tfstate"
    dynamodb_table = "terraform-state-lock"
    profile        = "mend-devops"
    region         = "eu-north-1"
  }
}

# Configure the AWS Provider
provider "aws" {
  alias   = "mend-devops"
  profile = "mend-devops"
  region  = "eu-north-1"
}

provider "aws" {
  alias   = "stav-devops"
  profile = "stav-devops"
  region  = "us-east-1"
}