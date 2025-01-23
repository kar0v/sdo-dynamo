locals {
  services = ["com.amazonaws.eu-central-1.ssm", "com.amazonaws.eu-central-1.ssmmessages", "com.amazonaws.eu-central-1.ec2messages"]
}

resource "aws_vpc_endpoint" "ssm" {
  count               = length(local.services)
  vpc_id              = aws_vpc.eks.id
  service_name        = local.services[count.index]
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.bastion.id, ]
  subnet_ids          = [aws_subnet.public-a.id, aws_subnet.public-b.id, aws_subnet.public-c.id]
  tags = {
    Name = "${local.services[count.index]}"
  }
}

resource "aws_vpc_endpoint" "eks" {
  service_name       = "com.amazonaws.eu-central-1.eks"
  vpc_id             = aws_vpc.eks.id
  subnet_ids         = [aws_subnet.eks-a.id, aws_subnet.eks-b.id, aws_subnet.eks-c.id]
  security_group_ids = [aws_security_group.eks.id]
  vpc_endpoint_type  = "Interface"
}

resource "aws_vpc_endpoint" "ecr" {
  vpc_id              = aws_vpc.eks.id
  service_name        = "com.amazonaws.eu-central-1.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.bastion.id, aws_security_group.eks.id]
  subnet_ids          = [aws_subnet.eks-a.id, aws_subnet.eks-b.id, aws_subnet.eks-c.id]
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.eks.id
  service_name        = "com.amazonaws.eu-central-1.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.bastion.id, aws_security_group.eks.id]
  subnet_ids          = [aws_subnet.eks-a.id, aws_subnet.eks-b.id, aws_subnet.eks-c.id]
}

