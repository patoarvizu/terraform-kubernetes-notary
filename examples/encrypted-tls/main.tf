module "notary" {
  source = "../../"
  encrypted_server_db_password = var.encrypted_server_db_password
  encrypted_signer_db_password = var.encrypted_signer_db_password
  encrypted_signer_alias_passphrase = var.encrypted_signer_alias_passphrase
  ca_cert_pem = base64decode(var.ca_cert_pem)
  server_cert_pem = base64decode(var.server_cert_pem)
  encrypted_server_cert_key = var.encrypted_server_cert_key
  signer_cert_pem = base64decode(var.signer_cert_pem)
  encrypted_signer_cert_key = var.encrypted_signer_cert_key
}