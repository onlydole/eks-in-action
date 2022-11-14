data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.30.3"

  manage_aws_auth_configmap = true
  cluster_name              = var.project_name
  cluster_version           = var.cluster_version
  subnet_ids                = module.vpc.private_subnets
  vpc_id                    = module.vpc.vpc_id
  cluster_enabled_log_types = var.cluster_enabled_log_types
  cluster_encryption_config = [
    {
      provider_key_arn = aws_kms_key.eks.arn
      resources        = ["secrets"]
    }
  ]

  eks_managed_node_groups = {
    worker = {
      min_size       = var.cluster_asg_min_size
      max_size       = var.cluster_asg_max_size
      desired_size   = var.cluster_asg_desired_capacity
      instance_types = [var.cluster_instance_type]
    }
  }
}
