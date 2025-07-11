###############################################################################
# Terraform settings
###############################################################################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.2.0"
    }
  }

  ########################################
  # Remote state backend configuration
  ########################################
  backend "s3" {
    bucket         = "minikube-us-east-1"
    key            = "terraform/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile = true
  }
}

###############################################################################
# AWS provider
###############################################################################
provider "aws" {
}
