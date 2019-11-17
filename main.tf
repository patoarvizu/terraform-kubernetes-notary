resource "tls_private_key" "ca" {
  algorithm = "ECDSA"
}

resource "tls_self_signed_cert" "ca" {
  key_algorithm = tls_private_key.ca.algorithm
  private_key_pem = tls_private_key.ca.private_key_pem
  subject {
    common_name = "Notary Root CA"
  }
  validity_period_hours = var.cert_validity_period_hours
  allowed_uses = [
    "cert_signing",
    "key_encipherment",
    "digital_signature",
  ]
  is_ca_certificate = true
}

resource "tls_private_key" "server" {
  algorithm = "ECDSA"
}

resource "tls_cert_request" "server" {
  key_algorithm = tls_private_key.server.algorithm
  private_key_pem = tls_private_key.server.private_key_pem
  subject {
    common_name = "notary-server"
  }
  dns_names = ["notary-server"]
}

resource "tls_locally_signed_cert" "server" {
  cert_request_pem = tls_cert_request.server.cert_request_pem
  ca_key_algorithm = tls_private_key.ca.algorithm
  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem = tls_self_signed_cert.ca.cert_pem
  validity_period_hours = var.cert_validity_period_hours
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
  ]
  is_ca_certificate = false
}

resource "tls_private_key" "signer" {
  algorithm = "ECDSA"
}

resource "tls_cert_request" "signer" {
  key_algorithm = tls_private_key.signer.algorithm
  private_key_pem = tls_private_key.signer.private_key_pem
  subject {
    common_name = "notary-signer"
  }
  dns_names = ["notary-signer"]
}

resource "tls_locally_signed_cert" "signer" {
  cert_request_pem = tls_cert_request.signer.cert_request_pem
  ca_key_algorithm = tls_private_key.ca.algorithm
  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem = tls_self_signed_cert.ca.cert_pem
  validity_period_hours = var.cert_validity_period_hours
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
  ]
  is_ca_certificate = false
}

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
            var.server_storage_db_url,
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
            "/migrate -path=/migrations/server/${var.storage_flavor} -database=${var.storage_flavor}://$(cat /migrate-configuration/db-url) up"
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
            var.signer_storage_db_url,
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
            "/migrate -path=/migrations/signer/${var.storage_flavor} -database=${var.storage_flavor}://$(cat /migrate-configuration/db-url) up"
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