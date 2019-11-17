resource "tls_private_key" "ca" {
  algorithm = "ECDSA"
}

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

resource "tls_private_key" "server" {
  algorithm = "ECDSA"
}

resource "tls_cert_request" "server" {
  key_algorithm = tls_private_key.server.algorithm
  private_key_pem = tls_private_key.server.private_key_pem
  subject {
    common_name = "notary-server"
  }
  dns_names = ["notary-server"]
}

resource "tls_locally_signed_cert" "server" {
  cert_request_pem = tls_cert_request.server.cert_request_pem
  ca_key_algorithm = tls_private_key.ca.algorithm
  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem = tls_self_signed_cert.ca.cert_pem
  validity_period_hours = var.cert_validity_period_hours
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
  ]
  is_ca_certificate = false
}

resource "tls_private_key" "signer" {
  algorithm = "ECDSA"
}

resource "tls_cert_request" "signer" {
  key_algorithm = tls_private_key.signer.algorithm
  private_key_pem = tls_private_key.signer.private_key_pem
  subject {
    common_name = "notary-signer"
  }
  dns_names = ["notary-signer"]
}

resource "tls_locally_signed_cert" "signer" {
  cert_request_pem = tls_cert_request.signer.cert_request_pem
  ca_key_algorithm = tls_private_key.ca.algorithm
  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem = tls_self_signed_cert.ca.cert_pem
  validity_period_hours = var.cert_validity_period_hours
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
  ]
  is_ca_certificate = false
}