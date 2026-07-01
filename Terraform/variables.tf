variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "eu-north-1"
}

variable "eks_cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = module.eks.cluster_name
}

variable "account_id" {
  description = "The AWS account ID"
  type        = string
  default     = "547320736290"
}