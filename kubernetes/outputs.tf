output "cluster_name" {
  description = "EKS Cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS Cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "kubeconfig_certificate_authority_data" {
  description = "EKS Cluster certificate authority data"
  value       = module.eks.cluster_certificate_authority_data
}
