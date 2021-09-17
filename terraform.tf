terraform {
  required_providers {
    # https://registry.terraform.io/providers/hashicorp/null/latest
    null = {
      source  = "hashicorp/null"
      version = "3.1.0"
    }

    # https://registry.terraform.io/providers/hashicorp/template/latest
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }

    # https://registry.terraform.io/providers/hashicorp/kubernetes/latest
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.4.1"
    }

    # https://registry.terraform.io/providers/hashicorp/aws/latest
    aws = {
      source  = "hashicorp/aws"
      version = "3.59.0"
    }

    # https://registry.terraform.io/providers/hashicorp/random/latest
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }

    # https://registry.terraform.io/providers/hashicorp/local/latest
    local = {
      source  = "hashicorp/local"
      version = "2.1.0"
    }
  }
}
