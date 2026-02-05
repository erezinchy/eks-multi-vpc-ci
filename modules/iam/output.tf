# modules/iam/outputs.tf

output "cluster_role_arn" {
  description = "The ARN of the EKS Cluster (Control Plane) role"
  value       = aws_iam_role.cluster.arn
}

output "node_role_arn" {
  description = "The ARN of the EKS Node Group role"
  value       = aws_iam_role.node.arn
}