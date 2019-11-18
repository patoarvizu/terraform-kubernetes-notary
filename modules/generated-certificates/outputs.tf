output "ca_cert_pem" {
  value = base64encode(tls_self_signed_cert.ca.cert_pem)
}

output "server_cert_pem" {
  value = base64encode(tls_locally_signed_cert.server.cert_pem)
}

output "encrypted_server_cert_key" {
  value = data.aws_kms_ciphertext.server_key.ciphertext_blob
}

output "signer_cert_pem" {
  value = base64encode(tls_locally_signed_cert.signer.cert_pem)
}

output "encrypted_signer_cert_key" {
  value = data.aws_kms_ciphertext.signer_key.ciphertext_blob
}