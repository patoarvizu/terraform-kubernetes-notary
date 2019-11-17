output "ca_cert_pem" {
  value = tls_self_signed_cert.ca.cert_pem
}

output "server_cert_pem" {
  value = tls_locally_signed_cert.server.cert_pem
}

output "server_cert_key" {
  value = tls_private_key.server.private_key_pem
}

output "signer_cert_pem" {
  value = tls_locally_signed_cert.signer.cert_pem
}

output "signer_cert_key" {
  value = tls_private_key.signer.private_key_pem
}