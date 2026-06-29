# 1. Creating VPC for EKS
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "eks-study-vpc"
  cidr = "10.0.0.0/16"

  # EKS requires at least 2 AZs for high availability, so we will create 2 public and 2 private subnets across 2 AZs
  azs = ["eu-north-1a", "eu-north-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true # We will use a single NAT Gateway to reduce costs, as this is a freetier account 

  public_subnet_tags = {
    "kubernetes.io/cluster/eks-commercial-study" = "shared" # Required for EKS cluster subnet discovery
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/eks-commercial-study" = "shared" # Required for EKS cluster subnet discovery
    "kubernetes.io/role/internal-elb"             = 1
  }
}

