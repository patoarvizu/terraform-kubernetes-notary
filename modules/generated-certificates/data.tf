data "aws_kms_ciphertext" "server_key" {
  key_id    = "alias/${var.kms_alias_name}"
  plaintext = tls_private_key.server.private_key_pem
}

data "aws_kms_ciphertext" "signer_key" {
  key_id    = "alias/${var.kms_alias_name}"
  plaintext = tls_private_key.signer.private_key_pem
}