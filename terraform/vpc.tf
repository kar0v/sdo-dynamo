resource "aws_vpc" "eks" {
  cidr_block           = "10.200.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "eks-vpc"
  }
}


#######################
### Private Subnets ###
#######################

resource "aws_subnet" "eks-a" {
  vpc_id            = aws_vpc.eks.id
  cidr_block        = "10.200.120.0/24"
  availability_zone = "eu-central-1a"
  tags = {
    Name = "private-eks-subnet-a"
  }
}

resource "aws_subnet" "eks-b" {
  vpc_id            = aws_vpc.eks.id
  cidr_block        = "10.200.121.0/24"
  availability_zone = "eu-central-1b"
  tags = {
    Name = "private-eks-subnet-b"
  }
}

resource "aws_subnet" "eks-c" {
  vpc_id            = aws_vpc.eks.id
  cidr_block        = "10.200.122.0/24"
  availability_zone = "eu-central-1c"
  tags = {
    Name = "private-eks-subnet-c"
  }
}

######################
### Public Subnets ###
######################

resource "aws_subnet" "public-a" {
  vpc_id            = aws_vpc.eks.id
  cidr_block        = "10.200.210.0/24"
  availability_zone = "eu-central-1a"
  tags = {
    Name = "public-a"
  }
}

resource "aws_subnet" "public-b" {
  vpc_id            = aws_vpc.eks.id
  cidr_block        = "10.200.211.0/24"
  availability_zone = "eu-central-1b"
  tags = {
    Name = "public-b"
  }
}

resource "aws_subnet" "public-c" {
  vpc_id            = aws_vpc.eks.id
  cidr_block        = "10.200.212.0/24"
  availability_zone = "eu-central-1c"
  tags = {
    Name = "public-c"
  }
}

###############
### Routing ###
###############


resource "aws_internet_gateway" "eks" {
  vpc_id = aws_vpc.eks.id
  tags = {
    Name = "eks-igw"
  }
}

resource "aws_route_table" "eks" {
  vpc_id = aws_vpc.eks.id
  tags = {
    Name = "eks-public-rt"
  }
}

# public route
resource "aws_route" "public" {
  route_table_id         = aws_route_table.eks.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.eks.id
}

locals {
  public_subnet_ids = [
    aws_subnet.public-a.id,
    aws_subnet.public-b.id,
    aws_subnet.public-c.id
  ]
}
resource "aws_route_table_association" "public" {
  count          = length(local.public_subnet_ids)
  subnet_id      = local.public_subnet_ids[count.index]
  route_table_id = aws_route_table.eks.id
}
