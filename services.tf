resource "kubernetes_service" "notary_db" {
  for_each = var.deploy_persistence == true ? {create: true} : {}
  metadata {
    name = "notary-db"
    namespace = var.namespace
  }
  spec {
    port {
      name = "mysql"
      port = 3306
      target_port = 3306
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