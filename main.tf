resource "kubernetes_config_map" "notarysql" {
  metadata {
    name = "notarysql"
    namespace = "${var.namespace}"
  }
  data = {
    for f in fileset("${path.module}/sql/${var.storage_flavor}-initdb.d", "*"):
    "${f}" => file("${path.module}/sql/${var.storage_flavor}-initdb.d/${f}")
  }
}

resource "kubernetes_config_map" "notary_migrations_server" {
  metadata {
    name = "notary-migrations-server"
    namespace = "${var.namespace}"
  }
  data = {
    for f in fileset("${path.module}/migrations/server/${var.storage_flavor}", "*"):
    "${f}" => file("${path.module}/migrations/server/${var.storage_flavor}/${f}")
  }
}

resource "kubernetes_config_map" "notary_migrations_signer" {
  metadata {
    name = "notary-migrations-signer"
    namespace = "${var.namespace}"
  }
  data = {
    for f in fileset("${path.module}/migrations/signer/${var.storage_flavor}", "*"):
    "${f}" => file("${path.module}/migrations/signer/${var.storage_flavor}/${f}")
  }
}

resource "kubernetes_config_map" "notary_config" {
  metadata {
    name = "notary-config"
    namespace = "${var.namespace}"
  }
  data = {
    "server-config.json" = templatefile("${path.module}/templates/server-config.json.tmpl", {
      server_port = var.server_port,
      server_trust_type = var.server_trust_type,
      server_trust_hostname = var.server_trust_hostname,
      server_trust_port = var.server_trust_port,
      logging_level = var.logging_level,
      storage_flavor = var.storage_flavor,
      server_storage_db_url = var.server_storage_db_url,
      authentication_enabled = var.authentication_enabled,
      authentication_type = var.authentication_type,
      authentication_options = var.authentication_options,
      caching_enabled = var.caching_enabled,
      caching_current_metadata = var.caching_current_metadata,
      caching_consistent_metadata = var.caching_consistent_metadata,
      gun_prefixes = join(",", var.gun_prefixes),
    })
    "signer-config.json" = templatefile("${path.module}/templates/signer-config.json.tmpl", {
      signer_port = var.signer_port,
      logging_level = var.logging_level,
      storage_flavor = var.storage_flavor,
      signer_storage_db_url = var.signer_storage_db_url,
      signer_default_alias = var.signer_default_alias,
    })
  }
}

resource "kubernetes_persistent_volume_claim" "notary_data" {
  metadata {
    name = "notary-data"
    namespace = "${var.namespace}"
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

resource "kubernetes_secret" "server_password" {
  metadata {
    name = "server-password"
    namespace = "${var.namespace}"
  }
  data = {
    password = var.server_db_password
  }
}

resource "kubernetes_secret" "signer_password" {
  metadata {
    name = "signer-password"
    namespace = "${var.namespace}"
  }
  data = {
    password = var.signer_db_password
  }
}

resource "kubernetes_deployment" "notary_db" {
  metadata {
    name = "notary-db"
    namespace = "${var.namespace}"
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
            "'%%'",
            "--right-delim",
            "'%%'",
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
          args = [
            "mysqld",
            "--innodb_file_per_table",
          ]
          env {
            name = "MYSQL_RANDOM_ROOT_PASSWORD"
            value = "yes"
          }
          image = var.storage_image
          name = "storage"
          port {
            container_port = 3306
            name = "mysql"
          }
          volume_mount {
            mount_path = "/var/lib/mysql"
            name = "notary-data"
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
            claim_name = kubernetes_persistent_volume_claim.notary_data.metadata.0.name
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