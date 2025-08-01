resource "aws_eks_cluster" "dev_eks" {
  name     = "dev_eks"
  role_arn = aws_iam_role.dev_role.arn

  vpc_config {
    subnet_ids = [for s in aws_subnet.public : s.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_role_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks_role_AmazonEKSServicePolicy
  ]

  tags = {
    Environment = "dev"
    Project     = "dev_eks"
  }
}

