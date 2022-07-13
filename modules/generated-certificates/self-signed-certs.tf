resource "tls_self_signed_cert" "ca" {
  private_key_pem = var.ca_cert_key == null ? tls_private_key.ca.private_key_pem : var.ca_cert_key
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