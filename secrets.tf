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
    "root-ca.crt" = tls_self_signed_cert.ca.cert_pem
    "notary-server.crt" = tls_locally_signed_cert.server.cert_pem
    "notary-server.key" = tls_private_key.server.private_key_pem
    "notary-signer.crt" = tls_locally_signed_cert.signer.cert_pem
    "notary-signer.key" = tls_private_key.signer.private_key_pem
  }
}