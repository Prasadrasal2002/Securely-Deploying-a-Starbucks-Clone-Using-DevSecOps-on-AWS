data "aws_iam_instance_profile" "jenkins_profile" {
  name = "eks-ec2-workernode-role" # Update if needed
}

resource "aws_iam_policy" "eks_access_from_jenkins" {
  name = "EKSAccessFromJenkins"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "eks:DescribeCluster",
        "eks:ListClusters",
        "eks:UpdateClusterConfig",
        "eks:DescribeNodegroup",
        "eks:ListNodegroups"
      ],
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "jenkins_eks_access_attach" {
  role       = data.aws_iam_instance_profile.jenkins_profile.role_name
  policy_arn = aws_iam_policy.eks_access_from_jenkins.arn
