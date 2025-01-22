### IAM ###
resource "aws_eks_cluster" "eks" {
  name = "eks"

  access_config {
    authentication_mode = "API"
  }

  role_arn = aws_iam_role.bastion.arn
  version  = "1.31"

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = false
    security_group_ids      = [aws_security_group.eks.id]
    subnet_ids = [
      aws_subnet.eks-a.id,
      aws_subnet.eks-b.id,
      aws_subnet.eks-c.id
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]
}

resource "aws_iam_role" "cluster" {
  name = "eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_eks_access_entry" "bastion" {
  depends_on    = [aws_eks_cluster.eks]
  cluster_name  = aws_eks_cluster.eks.name
  principal_arn = aws_iam_role.bastion.arn
  type          = "STANDARD"
}



resource "aws_eks_access_policy_association" "eks_admin" {
  cluster_name  = aws_eks_cluster.eks.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
  principal_arn = aws_iam_role.bastion.arn
  access_scope {
    type = "cluster"
  }
}


resource "aws_eks_access_policy_association" "eks_cluster_admin" {
  cluster_name  = aws_eks_cluster.eks.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_iam_role.bastion.arn
  access_scope {
    type = "cluster"
  }
}


# Nodes

resource "aws_eks_node_group" "eks" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "eks-ng"
  node_role_arn   = aws_iam_role.bastion.arn
  subnet_ids = [
    aws_subnet.eks-a.id,
    aws_subnet.eks-b.id,
    aws_subnet.eks-c.id
  ]
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
  depends_on = [aws_eks_cluster.eks]
}
