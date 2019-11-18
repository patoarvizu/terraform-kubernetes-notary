resource "kubernetes_deployment" "notary_db" {
  for_each = var.deploy_persistence == true ? {create: true} : {}
  metadata {
    name = "notary-db"
    namespace = var.namespace
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "notary"
        component = "notary-db"
      }
    }
    strategy {
      type = "Recreate"
    }
    template {
      metadata {
        labels = {
          app = "notary"
          component = "notary-db"
        }
      }
      spec {
        init_container {
          command = [
            "/gomplate",
            "--left-delim",
            "%%",
            "--right-delim",
            "%%",
            "--input-dir",
            "/sql-init-templates",
            "--output-dir",
            "/docker-entrypoint-initdb.d",
          ]
          image = "hairyhenderson/gomplate:v3"
          name = "gomplate"
          env {
            name = "SERVERPASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.server_password.metadata.0.name
                key = "password"
              }
            }
          }
          env {
            name = "SIGNERPASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.signer_password.metadata.0.name
                key = "password"
              }
            }
          }
          volume_mount {
            mount_path = "/docker-entrypoint-initdb.d"
            name = "sql-init"
          }
          volume_mount {
            mount_path = "/sql-init-templates"
            name = "notarysql"
          }
        }
        container {
          args = flatten([
            for f in local.db_container_args:
            f.args
            if f.flavor == var.storage_flavor
            ])
          dynamic "env" {
            for_each = [for e in local.db_environment_variables: {
              name = e.name
              value = e.value
            } if e.flavor == var.storage_flavor ]

            content {
              name = env.value.name
              value = env.value.value
            }
          }
          image = var.storage_image
          name = "storage"
          dynamic "port" {
            for_each = [for p in local.db_ports: {
              port = p.port
              name = p.name
            } if p.flavor == var.storage_flavor ]

            content {
              container_port = port.value.port
              name = port.value.name
            }
          }
          dynamic "volume_mount" {
            for_each = [for m in local.db_mounts: {
              mount_path = m.mount_path
              name = m.name
            } if m.flavor == var.storage_flavor ]

            content {
              mount_path = volume_mount.value.mount_path
              name = volume_mount.value.name
            }
          }
          volume_mount {
            mount_path = "/docker-entrypoint-initdb.d"
            name = "sql-init"
          }
          volume_mount {
            mount_path = "/sql-init-templates"
            name = "notarysql"
          }
        }
        volume {
          name = "notary-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.notary_data[each.key].metadata.0.name
          }
        }
        volume {
          name = "notarysql"
          config_map {
            name = "notarysql"
          }
        }
        volume {
          name = "sql-init"
          empty_dir {
            medium = ""
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "notary_server" {
  metadata {
    name = "notary-server"
    namespace = var.namespace
  }
  spec {
    replicas = var.server_replicas
    selector {
      match_labels = {
        app = "notary"
        component = "notary-server"
      }
    }
    strategy {
      rolling_update {
        max_unavailable = 0
      }
    }
    template {
      metadata {
        labels = {
          app = "notary"
          component = "notary-server"
        }
      }
      spec {
        init_container {
          command = [
            "/gomplate",
            "--left-delim",
            "%%",
            "--right-delim",
            "%%",
            "--input-dir",
            "/config-template",
            "--output-dir",
            "/config",
          ]
          image = "hairyhenderson/gomplate:v3"
          name = "gomplate"
          env {
            name = "PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.server_password.metadata.0.name
                key = "password"
              }
            }
          }
          volume_mount {
            mount_path = "/config"
            name = "config-rendered"
          }
          volume_mount {
            mount_path = "/config-template"
            name = "config-template"
          }
        }
        container {
          command = [
            "notary-server",
            "-config=/config/server-config.json",
          ]
          image = "notary:${var.server_image_version}"
          name = "server"
          port {
            container_port = var.server_port
            name = "https"
          }
          volume_mount {
            mount_path = "/config"
            name = "config-rendered"
          }
          volume_mount {
            mount_path = "/tls"
            name = "tls"
          }
        }
        volume {
          name = "config-template"
          config_map {
            name = kubernetes_config_map.notary_config.metadata.0.name
          }
        }
        volume {
          name = "tls"
          secret {
            secret_name = kubernetes_secret.notary_tls.metadata.0.name
          }
        }
        volume {
          name = "config-rendered"
          empty_dir {
            medium = ""
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "notary_signer" {
  metadata {
    name = "notary-signer"
    namespace = var.namespace
  }
  spec {
    replicas = var.signer_replicas
    selector {
      match_labels = {
        app = "notary"
        component = "notary-signer"
      }
    }
    strategy {
      rolling_update {
        max_unavailable = 0
      }
    }
    template {
      metadata {
        labels = {
          app = "notary"
          component = "notary-signer"
        }
      }
      spec {
        init_container {
          command = [
            "/gomplate",
            "--left-delim",
            "%%",
            "--right-delim",
            "%%",
            "--input-dir",
            "/config-template",
            "--output-dir",
            "/config",
          ]
          image = "hairyhenderson/gomplate:v3"
          name = "gomplate"
          env {
            name = "PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.signer_password.metadata.0.name
                key = "password"
              }
            }
          }
          volume_mount {
            mount_path = "/config"
            name = "config-rendered"
          }
          volume_mount {
            mount_path = "/config-template"
            name = "config-template"
          }
        }
        container {
          command = [
            "notary-signer",
            "-config=/config/signer-config.json",
          ]
          image = "notary:${var.signer_image_version}"
          name = "signer"
          env {
            name = "NOTARY_SIGNER_${upper(var.signer_default_alias)}"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.signer_alias.metadata.0.name
                key = "alias-secret"
              }
            }
          }
          port {
            container_port = var.signer_port
            name = "https"
          }
          volume_mount {
            mount_path = "/config"
            name = "config-rendered"
          }
          volume_mount {
            mount_path = "/tls"
            name = "tls"
          }
        }
        volume {
          name = "config-template"
          config_map {
            name = kubernetes_config_map.notary_config.metadata.0.name
          }
        }
        volume {
          name = "tls"
          secret {
            secret_name = kubernetes_secret.notary_tls.metadata.0.name
          }
        }
        volume {
          name = "config-rendered"
          empty_dir {
            medium = ""
          }
        }
      }
    }
  }
}