resource "aws_prometheus_workspace" "this" {
  alias = var.eks_cluster_name
}