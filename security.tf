# 1. Allow Backend Nodes to receive traffic from Gateway VPC
resource "aws_security_group_rule" "backend_allow_gateway_ingress" {
  type              = "ingress"
  from_port         = 8080 
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = [var.gateway_vpc_cidr] # Allow the entire Gateway VPC
  security_group_id = aws_eks_cluster.backend.vpc_config[0].cluster_security_group_id
  description       = "Allow Sentinel Gateway Proxy to reach Backend Services"
}

# 2. Allow Gateway Nodes to send traffic to Backend VPC (Egress)
resource "aws_security_group_rule" "gateway_to_backend_egress" {
  type              = "egress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = [var.backend_vpc_cidr]
  security_group_id = aws_eks_cluster.gateway.vpc_config[0].cluster_security_group_id
  description       = "Allow Gateway Nodes to send requests to Backend VPC"
}