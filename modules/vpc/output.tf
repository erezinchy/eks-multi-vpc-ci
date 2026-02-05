# modules/vpc/outputs.tf

output "vpc_id" {
  value = aws_vpc.this.id # Changed from eks_vpc to this
}

output "private_subnets" {
  value = aws_subnet.private[*].id
}

output "private_route_table_id" {
  value = aws_route_table.private.id # Now this resource actually exists!
}