data "aws_kms_secrets" "secrets" {
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