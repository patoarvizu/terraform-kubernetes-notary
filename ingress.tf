resource "kubernetes_ingress" "ingress" {
  for_each = length(var.ingress_hosts) > 0 ? {ingress: true} : {}
  metadata {
    name = "notary-ingress"
    namespace = var.namespace
    annotations = var.ingress_annotations
  }
  spec {
    dynamic "rule" {
      for_each = [for h in var.ingress_hosts: {
        host = h
      }]

      content {
        host = rule.value.host
        http {
          path {
            path = var.ingress_path
            backend {
              service_name = kubernetes_service.notary_server.metadata.0.name
              service_port = var.server_port
            }
          }
        }
      }
    }
    tls {
      hosts = var.ingress_tls_hosts
      secret_name = var.ingress_tls_secret_name
    }
  }
}
