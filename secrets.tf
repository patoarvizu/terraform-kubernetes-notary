resource "kubernetes_secret" "server_password" {
  metadata {
    name = "server-password"
    namespace = var.namespace
  }
  data = {
    password = data.aws_kms_secrets.secrets.plaintext["server_db_password"]
  }
}

resource "kubernetes_secret" "signer_password" {
  metadata {
    name = "signer-password"
    namespace = var.namespace
  }
  data = {
    password = data.aws_kms_secrets.secrets.plaintext["signer_db_password"]
  }
}

resource "kubernetes_secret" "signer_alias" {
  metadata {
    name = "signer-alias"
    namespace = var.namespace
  }
  data = {
    alias-secret = data.aws_kms_secrets.secrets.plaintext["signer_alias_passphrase"]
  }
}

resource "kubernetes_secret" "notary_tls" {
  metadata {
    name = "notary-tls"
    namespace = var.namespace
  }
  data = {
    "root-ca.crt" = var.ca_cert_pem
    "notary-server.crt" = var.server_cert_pem
    "notary-server.key" = var.server_cert_key
    "notary-signer.crt" = var.signer_cert_pem
    "notary-signer.key" = var.signer_cert_key
  }
}