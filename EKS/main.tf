module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.0.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"
  vpc_id          = var.vpc_id
  subnet_ids      = var.subnet_ids

  cluster_endpoint_public_access = true

  cluster_iam_role_name = var.eks_role_name
  cluster_iam_role_arn  = aws_iam_role.eks_cluster_role.arn

  node_groups = {
    default = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1

      instance_types = ["t3.medium"]
      iam_role_arn   = aws_iam_role.eks_node_role.arn
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
