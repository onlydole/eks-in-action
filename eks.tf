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
  version = "17.15.0"

  cluster_name              = var.project_name
  cluster_version           = var.cluster_version
  subnets                   = module.vpc.private_subnets
  vpc_id                    = module.vpc.vpc_id
  cluster_enabled_log_types = var.cluster_enabled_log_types
  write_kubeconfig          = var.cluster_write_kubeconfig
  cluster_encryption_config = [
    {
      provider_key_arn = aws_kms_key.eks.arn
      resources        = ["secrets"]
    }
  ]
  worker_groups = [
    {
      asg_desired_capacity = var.cluster_asg_desired_capacity
      asg_max_size         = var.cluster_asg_max_size
      instance_type        = var.cluster_instance_type
    }
  ]
}
