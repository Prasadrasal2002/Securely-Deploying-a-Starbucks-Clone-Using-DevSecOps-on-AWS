variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "prasad-eks"
}

variable "vpc_id" {
  description = "Existing VPC ID"
  type        = string
  default     = "vpc-059591b76b17a4457"
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
  default     = [
    "subnet-0956f23813c3f55b9",
    "subnet-028125de1c2117bb0",
    "subnet-017773966ffbc4fc4"
  ]
}

variable "eks_role_name" {
  description = "Name of the EKS IAM role"
  type        = string
  default     = "eks-cluster-role"
}

variable "node_role_name" {
  description = "Name of the EKS node IAM role"
  type        = string
  default     = "eks-node-role"
}
