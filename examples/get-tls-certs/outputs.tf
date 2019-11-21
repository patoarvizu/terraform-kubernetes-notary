output "ca_cert_pem" {
  value = "\"${module.tls.ca_cert_pem}\""
}

output "server_cert_pem" {
  value = "\"${module.tls.server_cert_pem}\""
}

output "encrypted_server_cert_key" {
  value = "\"${module.tls.encrypted_server_cert_key}\""
}

output "signer_cert_pem" {
  value = "\"${module.tls.signer_cert_pem}\""
}

output "encrypted_signer_cert_key" {
  value = "\"${module.tls.encrypted_signer_cert_key}\""
}