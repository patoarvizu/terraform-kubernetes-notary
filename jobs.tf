resource "kubernetes_job" "notary_server_migrate" {
  metadata {
    name = "notary-server-migrate"
    namespace = var.namespace
  }
  spec {
    completions = 1
    parallelism = 1
    backoff_limit = 100
    template {
      metadata {
        labels = {
          app = "notary"
          component = "notary-server-migrate"
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
            "--in",
            "${var.storage_flavor}://${var.server_storage_db_url}",
            "--out",
            "/migrate-configuration/db-url",
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
            mount_path = "/migrate-configuration"
            name = "migrate-configuration"
          }
        }
        container {
          command = [
            "sh",
            "-c",
            "/migrate -path=/migrations/server/${var.storage_flavor} -database=$(cat /migrate-configuration/db-url) up"
          ]
          image = "migrate/migrate:${var.migrate_version}"
          name = "migrate"
          volume_mount {
            mount_path = "/migrations/server/${var.storage_flavor}"
            name = "migrations-server"
          }
          volume_mount {
            mount_path = "/tls"
            name = "tls"
          }
          volume_mount {
            mount_path = "/migrate-configuration"
            name = "migrate-configuration"
          }
        }
        restart_policy = "OnFailure"
        volume {
          name = "migrations-server"
          config_map {
            name = kubernetes_config_map.notary_migrations_server.metadata.0.name
          }
        }
        volume {
          name = "tls"
          secret {
            secret_name = kubernetes_secret.notary_tls.metadata.0.name
          }
        }
        volume {
          name = "migrate-configuration"
          empty_dir {
            medium = ""
          }
        }
      }
    }
  }
}

resource "kubernetes_job" "notary_signer_migrate" {
  metadata {
    name = "notary-signer-migrate"
    namespace = var.namespace
  }
  spec {
    completions = 1
    parallelism = 1
    backoff_limit = 100
    template {
      metadata {
        labels = {
          app = "notary"
          component = "notary-signer-migrate"
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
            "--in",
            "${var.storage_flavor}://${var.signer_storage_db_url}",
            "--out",
            "/migrate-configuration/db-url",
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
            mount_path = "/migrate-configuration"
            name = "migrate-configuration"
          }
        }
        container {
          command = [
            "sh",
            "-c",
            "/migrate -path=/migrations/signer/${var.storage_flavor} -database=$(cat /migrate-configuration/db-url) up"
          ]
          image = "migrate/migrate:${var.migrate_version}"
          name = "migrate"
          volume_mount {
            mount_path = "/migrations/signer/${var.storage_flavor}"
            name = "migrations-signer"
          }
          volume_mount {
            mount_path = "/tls"
            name = "tls"
          }
          volume_mount {
            mount_path = "/migrate-configuration"
            name = "migrate-configuration"
          }
        }
        restart_policy = "OnFailure"
        volume {
          name = "migrations-signer"
          config_map {
            name = kubernetes_config_map.notary_migrations_signer.metadata.0.name
          }
        }
        volume {
          name = "tls"
          secret {
            secret_name = kubernetes_secret.notary_tls.metadata.0.name
          }
        }
        volume {
          name = "migrate-configuration"
          empty_dir {
            medium = ""
          }
        }
      }
    }
  }
}