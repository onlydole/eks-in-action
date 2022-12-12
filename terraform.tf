terraform {
  required_providers {

    # https://registry.terraform.io/providers/hashicorp/kubernetes/latest
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.12.1"
    }

    # https://registry.terraform.io/providers/hashicorp/aws/latest
    aws = {
      source  = "hashicorp/aws"
      version = "4.46.0"
    }

    # https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release
    helm = {
      source  = "hashicorp/helm"
      version = "2.6.0"
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
