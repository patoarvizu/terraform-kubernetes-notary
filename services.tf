resource "kubernetes_service" "notary_db" {
  for_each = var.deploy_persistence == true ? {create: true} : {}
  metadata {
    name = "notary-db"
    namespace = var.namespace
  }
  spec {
    dynamic "port" {
      for_each = [for p in local.db_ports: {
          port = p.port
          name = p.name
      } if p.flavor == var.storage_flavor ]

      content {
        name = port.value.name
        port = port.value.port
        target_port = port.value.name
      }
    }
    selector = {
      app = "notary"
      component = "notary-db"
    }
  }
}

resource "kubernetes_service" "notary_signer" {
  metadata {
    name = "notary-signer"
    namespace = var.namespace
  }
  spec {
    port {
      name = "https"
      port = var.signer_port
      target_port = var.signer_port
    }
    selector = {
      app = "notary"
      component = "notary-signer"
    }
  }
}