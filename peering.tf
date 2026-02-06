# Establish VPC Peering Connection
resource "aws_vpc_peering_connection" "sentinel_split" {
  vpc_id        = module.vpc_gateway.vpc_id
  peer_vpc_id   = module.vpc_backend.vpc_id
  auto_accept   = true

  tags = {
    Name = "peering-gateway-to-backend"
  }
}

# Gateway -> Backend
resource "aws_route" "gateway_to_backend" {
  route_table_id            = module.vpc_gateway.private_route_table_id
  destination_cidr_block    = var.backend_vpc_cidr 
  vpc_peering_connection_id = aws_vpc_peering_connection.sentinel_split.id
}

# Backend -> Gateway
resource "aws_route" "backend_to_gateway" {
  route_table_id            = module.vpc_backend.private_route_table_id
  destination_cidr_block    = var.gateway_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.sentinel_split.id
}