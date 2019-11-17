module "tls" {
  source = "../../modules/generated-certificates"
}

module "notary" {
  source = "../../"
  encrypted_server_db_password = var.encrypted_server_db_password
  encrypted_signer_db_password = var.encrypted_signer_db_password
  encrypted_signer_alias_passphrase = var.encrypted_signer_alias_passphrase
  ca_cert_pem = module.tls.ca_cert_pem
  server_cert_pem = module.tls.server_cert_pem
  server_cert_key = module.tls.server_cert_key
  signer_cert_pem = module.tls.signer_cert_pem
  signer_cert_key = module.tls.signer_cert_key
}