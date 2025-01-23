
####################################
### Bastion host in Private Zone ###
####################################

resource "aws_iam_role" "bastion" {
  name = "bastion"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = [
            "ec2.amazonaws.com",
            "eks.amazonaws.com"
          ]
        },
        Action = "sts:AssumeRole"
      },
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::288761731382:root"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "ssm_core_policy_attachment" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "eks_bastion_policies" {
  count = 2
  role  = aws_iam_role.bastion.name

  policy_arn = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  ][count.index]
}

resource "aws_iam_policy" "eks_bastion_custom_policy" {
  name        = "EKSManagementPolicy"
  description = "IAM policy for EKS cluster management from bastion"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:UpdateClusterConfig",
          "eks:UpdateClusterVersion"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ssm:SendCommand",
          "ssm:GetCommandInvocation"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeRouteTables"
        ],
        Resource = "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:AccessKubernetesApi",
          "sts:AssumeRole"
        ],
        "Resource" : "*"
      }

    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_bastion_custom_policy_attachment" {
  role       = aws_iam_role.bastion.name
  policy_arn = aws_iam_policy.eks_bastion_custom_policy.arn
}


resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "SSM_EC2_Instance_Profile"
  role = aws_iam_role.bastion.name
}


# AMI

data "aws_ami" "amzn" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"]

}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amzn.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public-a.id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  iam_instance_profile        = aws_iam_instance_profile.ssm_instance_profile.name
  associate_public_ip_address = true
  tags = {
    Name = "bastion"
  }
  user_data = <<-EOF
                #!/bin/bash
                echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKzT78DlMZzU9oT1KMYw6da6XfjaWnGiD3uSa16GVW7g Karov' > /root/.ssh/authorized_keys
                EOF

}
