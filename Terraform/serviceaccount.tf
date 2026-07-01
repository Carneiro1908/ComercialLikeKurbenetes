resource "kubernetes_namespace" "prometheus" {
  metadata { name = "prometheus" }
}

resource "kubernetes_service_account" "amp_ingest" {
  metadata {
    name      = "amp-ingest"
    namespace = kubernetes_namespace.prometheus.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.amp_ingest.arn
    }
  }
}

resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.prometheus.metadata[0].name
  version    = "58.2.1"

  values = [
    yamlencode({
      prometheus = {
        serviceAccount = {
          create = false
          name   = kubernetes_service_account.amp_ingest.metadata[0].name
        }
        prometheusSpec = {
          remoteWrite = [{
            url   = "https://aps-workspaces.${var.aws_region}.amazonaws.com/workspaces/${aws_prometheus_workspace.this.id}/api/v1/remote_write"
            sigv4 = { region = var.aws_region }
          }]
        }
      }
      grafana = { enabled = false }
    })
  ]
}