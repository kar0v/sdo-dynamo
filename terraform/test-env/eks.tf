###############
### CLUSTER ###
###############
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

resource "aws_eks_addon" "ebs_volume" {
  cluster_name = aws_eks_cluster.eks.name
  addon_name   = "ebs-csi-driver"
  depends_on   = [aws_eks_cluster.eks]
}

####################
### CLUSTER ROLE ###
####################

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

######################
### CLUSTER ACCESS ###
######################

locals {
  cluster_policy_arns = [
    "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy",
    "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy",
  ]
  node_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  ]
}

resource "aws_eks_access_entry" "bastion" {
  depends_on    = [aws_eks_cluster.eks]
  cluster_name  = aws_eks_cluster.eks.name
  principal_arn = aws_iam_role.bastion.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "bastion" {
  count         = 2
  cluster_name  = aws_eks_cluster.eks.name
  policy_arn    = local.cluster_policy_arns[count.index]
  principal_arn = aws_iam_role.bastion.arn
  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_entry" "personal" {
  count         = length(var.personal_arn) > 0 ? 1 : 0
  depends_on    = [aws_eks_cluster.eks]
  cluster_name  = aws_eks_cluster.eks.name
  principal_arn = var.personal_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "personal" {
  count         = length(var.personal_arn) > 0 ? 2 : 0
  cluster_name  = aws_eks_cluster.eks.name
  policy_arn    = local.cluster_policy_arns[count.index]
  principal_arn = var.personal_arn
  access_scope {
    type = "cluster"
  }
}


#############
### NODES ###
#############

resource "aws_iam_role" "eks_node_group" {
  name = "eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "node_group_policies" {
  count      = 4
  role       = aws_iam_role.eks_node_group.name
  policy_arn = local.node_policy_arns[count.index]
}

resource "aws_eks_access_entry" "nodes" {
  depends_on    = [aws_eks_cluster.eks]
  cluster_name  = aws_eks_cluster.eks.name
  principal_arn = aws_iam_role.eks_node_group.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "nodes" {
  count         = 2
  cluster_name  = aws_eks_cluster.eks.name
  policy_arn    = local.cluster_policy_arns[count.index]
  principal_arn = aws_iam_role.eks_node_group.arn
  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_node_group" "eks" {

  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "eks-ng"
  node_role_arn   = aws_iam_role.eks_node_group.arn
  ami_type        = "AL2023_x86_64_STANDARD"
  subnet_ids = [
    aws_subnet.eks-a.id,
    aws_subnet.eks-b.id,
    aws_subnet.eks-c.id
  ]
  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 1
  }
  instance_types = ["t3.medium"]
  depends_on     = [aws_eks_cluster.eks, aws_vpc_endpoint.eks]
  tags = {
    Name = "on-demand"
  }
}
