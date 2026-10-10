output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "EKS Kubernetes API endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = aws_eks_cluster.main.arn
}

output "node_group_name" {
  description = "Name of the EKS managed node group"
  value       = aws_eks_node_group.main.node_group_name
}

output "node_role_arn" {
  description = "IAM role used by EKS worker nodes"
  value       = aws_iam_role.eks_nodes.arn
}
output "oidc_provider_arn" {
  description = "IAM OIDC provider ARN for EKS"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL for EKS"
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
}
