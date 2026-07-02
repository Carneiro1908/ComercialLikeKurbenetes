resource "kubernetes_namespace_v1" "prometheus" {
  metadata { name = "prometheus" }

  depends_on = [module.eks]
}

resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace_v1.prometheus.metadata[0].name
  version    = "58.2.1"

  # Longer timeout: on t3.micro/t3.small nodes, pulling and starting all
  # the stack's pods (Prometheus, Grafana, Alertmanager, exporters) can
  # take longer than the Helm provider's default timeout.
  timeout = 900

  values = [
    yamlencode({
      prometheus = {
        prometheusSpec = {
          # No Amazon Managed Prometheus: data is stored only locally in-cluster.
          retention = "7d"
          resources = {
            requests = { cpu = "100m", memory = "256Mi" }
            limits   = { cpu = "300m", memory = "512Mi" }
          }
        }
      }

      grafana = {
        enabled       = true
        adminPassword = var.grafana_admin_password
        service = {
          type = "LoadBalancer"
        }
        resources = {
          requests = { cpu = "50m", memory = "128Mi" }
          limits   = { cpu = "150m", memory = "256Mi" }
        }
      }

      # On small clusters, Alertmanager can be too heavy for the available
      # resources. Disabled by default; enable later if you need alerting.
      alertmanager = {
        enabled = false
      }

      kubeStateMetrics = { enabled = true }
      nodeExporter     = { enabled = true }
      prometheusOperator = {
        resources = {
          requests = { cpu = "50m", memory = "128Mi" }
          limits   = { cpu = "100m", memory = "256Mi" }
        }
      }
    })
  ]

  depends_on = [kubernetes_namespace_v1.prometheus]
}