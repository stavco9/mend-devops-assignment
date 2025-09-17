locals {
  tags = {
    Environment = var.environment
    Region      = data.aws_region.current.name
    Project     = var.project
    Owner       = var.owner
    ManagedBy   = "terraform"
  }

  cluster_name       = format("k8s-%s-%s", var.project, var.environment)
  cluster_dns_suffix = format("k8s.%s", var.dns_suffix)
}

data "aws_region" "current" {}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = local.cluster_name
  kubernetes_version = var.kubernetes_version

  addons = {
    coredns = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
  }

  # Optional
  endpoint_public_access       = true
  endpoint_public_access_cidrs = ["0.0.0.0/0"]

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  # Create just the IAM resources for EKS Auto Mode for use with custom node pools
  create_auto_mode_iam_resources = true

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets_ids

  enable_irsa = true

  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    general_node_group = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = var.nodes_instance_types

      min_size     = var.nodes_min_size
      max_size     = var.nodes_max_size
      desired_size = var.nodes_desired_size
    }
  }

  cluster_tags = { Cluster = local.cluster_name }

  tags = local.tags
}