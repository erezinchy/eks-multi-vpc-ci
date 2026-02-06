# modules/vpc/main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Or your preferred version
    }
  }
}

variable "vpc_name" {
  type        = string
  description = "Name of the VPC for the Rapyd Sentinel project"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}


variable "public_subnets" { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "azs" { type = list(string) }

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.vpc_name}-igw" }
}

# NAT Gateway logic so private nodes can talk to the internet
resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id # Puts NAT in the first public subnet
  tags          = { Name = "${var.vpc_name}-nat" }
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name                     = "${var.vpc_name}-public-${count.index}"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]
  tags = {
    Name                              = "${var.vpc_name}-private-${count.index}"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"    
  }
}

# --- ROUTE TABLES (This is what was missing!) ---

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = { Name = "${var.vpc_name}-public-rt" }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }
  tags = { Name = "${var.vpc_name}-private-rt" }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}