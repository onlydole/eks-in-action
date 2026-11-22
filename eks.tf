data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

# https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.29.0"

  name               = var.project_name
  kubernetes_version = var.cluster_version
  subnet_ids         = module.vpc.private_subnets
  vpc_id             = module.vpc.vpc_id
  enabled_log_types  = var.cluster_enabled_log_types

  # Since v21 the module creates clusters without the default self-managed
  # add-ons, so install the networking add-ons through the EKS add-on API.
  # The VPC CNI goes in before the node group so nodes can become Ready.
  addons = {
    vpc-cni = {
      before_compute = true
    }
    kube-proxy = {}
    coredns    = {}
  }

  # Keep the public API endpoint so Terraform can reach the cluster
  # with the Kubernetes and Helm providers. Narrow the allowed CIDRs
  # with var.cluster_endpoint_public_access_cidrs.
  endpoint_public_access       = true
  endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  endpoint_private_access      = true

  # Access entries replace the aws-auth ConfigMap. EKS adds entries for
  # managed node group roles on its own, and this grants the identity
  # running Terraform cluster admin access. For a cluster created by an
  # older version of this example, see "Upgrading an existing cluster"
  # in the README first.
  enable_cluster_creator_admin_permissions = true

  create_kms_key = false
  encryption_config = {
    provider_key_arn = aws_kms_key.eks.arn
    resources        = ["secrets"]
  }

  eks_managed_node_groups = {
    worker = {
      min_size       = var.cluster_asg_min_size
      max_size       = var.cluster_asg_max_size
      desired_size   = var.cluster_asg_desired_capacity
      instance_types = [var.cluster_instance_type]
    }
  }
}
