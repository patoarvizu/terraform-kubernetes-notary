resource "tls_self_signed_cert" "ca" {
  key_algorithm = tls_private_key.ca.algorithm
  private_key_pem = tls_private_key.ca.private_key_pem
  subject {
    common_name = "Notary Root CA"
  }
  validity_period_hours = var.cert_validity_period_hours
  allowed_uses = [
    "cert_signing",
    "key_encipherment",
    "digital_signature",
  ]
  is_ca_certificate = true
}