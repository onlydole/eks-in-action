# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones
# Filter out opt-in availability zones (local zones, as an example)
data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.9.0"

  name = var.project_name
  cidr = var.cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets

  enable_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/role/elb"                    = 1
    "kubernetes.io/cluster/${var.project_name}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"           = 1
    "kubernetes.io/cluster/${var.project_name}" = "shared"
  }

  tags = {
    Operator = "Terraform"
  }
}

locals {
  private_subnets = [
    cidrsubnet(var.cidr, 8, 1),
    cidrsubnet(var.cidr, 8, 2),
    cidrsubnet(var.cidr, 8, 3)
  ]
  public_subnets = [
    cidrsubnet(var.cidr, 8, 4),
    cidrsubnet(var.cidr, 8, 5),
    cidrsubnet(var.cidr, 8, 6)
  ]
}
