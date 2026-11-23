terraform {
  required_version = ">= 1.5.7"

  required_providers {

    # https://registry.terraform.io/providers/hashicorp/kubernetes/latest
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.5.0"
    }

    # https://registry.terraform.io/providers/hashicorp/aws/latest
    aws = {
      source  = "hashicorp/aws"
      version = "6.73.0"
    }

    # https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release
    helm = {
      source  = "hashicorp/helm"
      version = "3.3.0"
    }
  }
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "onlydole"

    workspaces {
      name = "eks-in-action"
    }
  }
}
