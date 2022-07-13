resource "kubernetes_config_map" "notarysql" {
  for_each = var.deploy_persistence == true ? {create: true} : {}
  metadata {
    name = "notarysql"
    namespace = var.namespace
  }
  data = {
    for f in fileset("${path.module}/sql/${var.storage_flavor}-initdb.d", "*"):
    "${f}" => file("${path.module}/sql/${var.storage_flavor}-initdb.d/${f}")
  }
}

resource "kubernetes_config_map" "notary_migrations_server" {
  for_each = var.run_migration_jobs == true ? {migrate: true} : {}
  metadata {
    name = "notary-migrations-server"
    namespace = var.namespace
  }
  data = {
    for f in fileset("${path.module}/migrations/server/${var.storage_flavor}", "*"):
    "${f}" => file("${path.module}/migrations/server/${var.storage_flavor}/${f}")
  }
}

resource "kubernetes_config_map" "notary_migrations_signer" {
  for_each = var.run_migration_jobs == true ? {migrate: true} : {}
  metadata {
    name = "notary-migrations-signer"
    namespace = var.namespace
  }
  data = {
    for f in fileset("${path.module}/migrations/signer/${var.storage_flavor}", "*"):
    "${f}" => file("${path.module}/migrations/signer/${var.storage_flavor}/${f}")
  }
}

resource "kubernetes_config_map" "notary_config" {
  metadata {
    name = "notary-config"
    namespace = var.namespace
  }
  data = {
    "server-config.json" = templatefile("${path.module}/templates/server-config.json.tmpl", {
      server_port = var.server_port,
      server_trust_type = var.server_trust_type,
      server_trust_hostname = var.server_trust_hostname,
      server_trust_port = var.server_trust_port,
      logging_level = var.logging_level,
      storage_flavor = var.storage_flavor,
      server_storage_db_url = "${var.server_storage_db_url}",
      authentication_enabled = var.authentication_enabled,
      authentication_type = var.authentication_type,
      authentication_options = var.authentication_options,
      caching_enabled = var.caching_enabled,
      caching_current_metadata = var.caching_current_metadata,
      caching_consistent_metadata = var.caching_consistent_metadata,
      gun_prefixes = jsonencode(var.gun_prefixes),
    })
    "signer-config.json" = templatefile("${path.module}/templates/signer-config.json.tmpl", {
      signer_port = var.signer_port,
      logging_level = var.logging_level,
      storage_flavor = var.storage_flavor,
      signer_storage_db_url = "${var.signer_storage_db_url}"
      signer_default_alias = var.signer_default_alias,
    })
  }
}