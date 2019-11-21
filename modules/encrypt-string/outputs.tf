output "encrypted_text" {
  value = data.aws_kms_ciphertext.secret.ciphertext_blob
}