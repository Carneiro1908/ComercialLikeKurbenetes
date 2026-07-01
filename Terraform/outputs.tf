output "amp_workspace_id"       { value = aws_prometheus_workspace.this.id }
output "amg_workspace_endpoint" { value = aws_grafana_workspace.this.endpoint }