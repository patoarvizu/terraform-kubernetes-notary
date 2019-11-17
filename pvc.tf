resource "kubernetes_persistent_volume_claim" "notary_data" {
  for_each = var.deploy_persistence == true ? {create: true} : {}
  metadata {
    name = "notary-data"
    namespace = var.namespace
  }
  spec {
    storage_class_name = var.storage_class_name
    access_modes = [
      "ReadWriteOnce"
    ]
    resources {
      requests = {
        storage = var.storage_size
      }
    }
  }
  wait_until_bound = false
}