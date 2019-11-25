module "tls" {
  source = "../../modules/generated-certificates"
  kms_alias_name = var.kms_alias_name
}

module "encrypted_server_db_password" {
  source = "../../modules/encrypt-string"
  text_to_encrypt = var.server_db_password
  kms_alias_name = var.kms_alias_name
}

module "encrypted_signer_db_password" {
  source = "../../modules/encrypt-string"
  text_to_encrypt = var.signer_db_password
  kms_alias_name = var.kms_alias_name
}

module "encrypted_signer_alias_passphrase" {
  source = "../../modules/encrypt-string"
  text_to_encrypt = var.signer_alias_passphrase
  kms_alias_name = var.kms_alias_name
}