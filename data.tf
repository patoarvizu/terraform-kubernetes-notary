data "aws_kms_secrets" "passwords" {
  secret {
    name = "server_db_password"
    payload = var.encrypted_server_db_password
  }
  secret {
    name = "signer_db_password"
    payload = var.encrypted_signer_db_password
  }
  secret {
    name = "signer_alias_passphrase"
    payload = var.encrypted_signer_alias_passphrase
  }
}

data "aws_kms_secrets" "tls" {
  secret {
    name = "server_cert_key"
    payload = var.encrypted_server_cert_key
  }
  secret {
    name = "signer_cert_key"
    payload = var.encrypted_signer_cert_key
  }
}