provider "aws" {
  region = "us-east-2"
}

##########################
# VPC
##########################
resource "aws_vpc" "eks_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "eks-vpc"
  }
}

##########################
# Internet Gateway
##########################
resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "eks-igw"
  }
}

##########################
# Public Subnets
##########################
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = element(["10.0.1.0/24", "10.0.2.0/24"], count.index)
  availability_zone       = element(["us-east-2a", "us-east-2b"], count.index)
  map_public_ip_on_launch = true

  tags = {
    Name                            = "public-subnet-${count.index}"
    "kubernetes.io/role/elb"        = "1"
    "kubernetes.io/cluster/example" = "owned"
  }
}

##########################
# Private Subnets
##########################
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = element(["10.0.3.0/24", "10.0.4.0/24"], count.index)
  availability_zone = element(["us-east-2a", "us-east-2b"], count.index)

  tags = {
    Name                                    = "private-subnet-${count.index}"
    "kubernetes.io/role/internal-elb"       = "1"
    "kubernetes.io/cluster/example"         = "owned"
  }
}

##########################
# NAT Gateway
##########################
resource "aws_eip" "nat" {
  tags = {
    Name = "nat_eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "eks-nat-gateway"
  }
}

