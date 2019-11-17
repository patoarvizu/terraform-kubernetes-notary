module "tls" {
  source = "../../modules/generated-certificates"
}

data "aws_kms_ciphertext" "server_key" {
  key_id    = "alias/${var.alias_name}"
  plaintext = module.tls.server_cert_key
}

data "aws_kms_ciphertext" "signer_key" {
  key_id    = "alias/${var.alias_name}"
  plaintext = module.tls.signer_cert_key
}

module "notary" {
  source = "../../"
  encrypted_server_db_password = var.encrypted_server_db_password
  encrypted_signer_db_password = var.encrypted_signer_db_password
  encrypted_signer_alias_passphrase = var.encrypted_signer_alias_passphrase
  ca_cert_pem = module.tls.ca_cert_pem
  server_cert_pem = module.tls.server_cert_pem
  encrypted_server_cert_key = data.aws_kms_ciphertext.server_key.ciphertext_blob
  signer_cert_pem = module.tls.signer_cert_pem
  encrypted_signer_cert_key = data.aws_kms_ciphertext.signer_key.ciphertext_blob
}