# create ecr & ecr endpoints for the eks cluster

resource "aws_ecr_repository" "feedback_logger" {
  name = "feedback-logger"
}

resource "aws_ecr_repository" "feedback_db" {
  name = "feedback-db"
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

