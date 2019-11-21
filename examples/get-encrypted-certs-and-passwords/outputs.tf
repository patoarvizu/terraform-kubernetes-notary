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

output "encrypted_server_db_password" {
  value = "\"${module.encrypted_server_db_password.encrypted_text}\""
}

output "encrypted_signer_db_password" {
  value = "\"${module.encrypted_signer_db_password.encrypted_text}\""
}

output "encrypted_signer_alias_passphrase" {
  value = "\"${module.encrypted_signer_alias_passphrase.encrypted_text}\""
}