resource "tls_locally_signed_cert" "server" {
  cert_request_pem = tls_cert_request.server.cert_request_pem
  ca_private_key_pem = var.ca_cert_key == null ? tls_private_key.ca.private_key_pem : var.ca_cert_key
  ca_cert_pem = tls_self_signed_cert.ca.cert_pem
  validity_period_hours = var.cert_validity_period_hours
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
  ]
  is_ca_certificate = false
}

resource "tls_locally_signed_cert" "signer" {
  cert_request_pem = tls_cert_request.signer.cert_request_pem
  ca_private_key_pem = var.ca_cert_key == null ? tls_private_key.ca.private_key_pem : var.ca_cert_key
  ca_cert_pem = tls_self_signed_cert.ca.cert_pem
  validity_period_hours = var.cert_validity_period_hours
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
  ]
  is_ca_certificate = false
}