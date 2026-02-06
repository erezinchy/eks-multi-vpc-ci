# --- 1. SETUP ---
# We fetch the AZs dynamically based on the region provided in var.aws_region
data "aws_availability_zones" "available" { state = "available" }

# --- 2. NETWORKING LAYER (GATEWAY) ---
module "vpc_gateway" {
  source           = "./modules/vpc"  
  vpc_name         = "${var.gateway_cluster_name}-vpc"
  eks_cluster_name = var.gateway_cluster_name
  vpc_cidr         = var.gateway_vpc_cidr
  public_subnets   = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnets  = ["10.1.11.0/24", "10.1.12.0/24"]
  azs              = slice(data.aws_availability_zones.available.names, 0, 2)
}

# --- 3. NETWORKING LAYER (BACKEND) ---
module "vpc_backend" {
  source           = "./modules/vpc"
  vpc_name         = "${var.backend_cluster_name}-vpc"
  eks_cluster_name = var.backend_cluster_name
  vpc_cidr         = var.backend_vpc_cidr
  public_subnets   = ["10.2.1.0/24", "10.2.2.0/24"]
  private_subnets  = ["10.2.11.0/24", "10.2.12.0/24"]
  azs              = slice(data.aws_availability_zones.available.names, 0, 2)
}

# --- 4. IAM LAYER ---
module "iam_gateway" {
  source       = "./modules/iam"
  cluster_name = var.gateway_cluster_name
}

module "iam_backend" {
  source       = "./modules/iam"
  cluster_name = var.backend_cluster_name
}

# --- 5. EKS CLUSTERS ---
resource "aws_eks_cluster" "gateway" {
  name     = var.gateway_cluster_name
  role_arn = module.iam_gateway.cluster_role_arn
  vpc_config {
    subnet_ids              = module.vpc_gateway.private_subnets
    endpoint_private_access = true
    endpoint_public_access  = true
  }
}

resource "aws_eks_cluster" "backend" {
  name     = var.backend_cluster_name
  role_arn = module.iam_backend.cluster_role_arn
  vpc_config {
    subnet_ids              = module.vpc_backend.private_subnets
    endpoint_private_access = true
    endpoint_public_access  = true
  }
}

# --- 6. NODE GROUPS ---
resource "aws_eks_node_group" "gateway_nodes" {
  cluster_name    = aws_eks_cluster.gateway.name
  node_group_name = "${var.gateway_cluster_name}-nodes"
  node_role_arn   = module.iam_gateway.node_role_arn
  subnet_ids      = module.vpc_gateway.private_subnets
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
  instance_types = ["t3.medium"]
}

resource "aws_eks_node_group" "backend_nodes" {
  cluster_name    = aws_eks_cluster.backend.name
  node_group_name = "${var.backend_cluster_name}-nodes"
  node_role_arn   = module.iam_backend.node_role_arn
  subnet_ids      = module.vpc_backend.private_subnets
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
  instance_types = ["t3.medium"]
}