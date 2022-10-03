resource "kubernetes_ingress_v1" "ingress" {
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
              service {
                name = kubernetes_service.notary_server.metadata.0.name
                port {
                  number = var.server_port
                }
              }
            }
          }
        }
      }
    }
    dynamic "tls" {
      for_each = var.ingress_tls_hosts == null ? [] : var.ingress_tls_hosts
      content {
        hosts = var.ingress_tls_hosts
        secret_name = var.ingress_tls_secret_name
      }
    }
  }
}
