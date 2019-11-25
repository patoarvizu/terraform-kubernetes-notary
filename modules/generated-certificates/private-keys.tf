# If the 'ca_cert_key' variable is set, then this resource is generated but not used
resource "tls_private_key" "ca" {
  algorithm = var.private_key_algorithm
  ecdsa_curve = var.ecdsa_curve
  rsa_bits = var.rsa_bits
}

resource "tls_private_key" "server" {
  algorithm = var.private_key_algorithm
  ecdsa_curve = var.ecdsa_curve
  rsa_bits = var.rsa_bits
}

resource "tls_private_key" "signer" {
  algorithm = var.private_key_algorithm
  ecdsa_curve = var.ecdsa_curve
  rsa_bits = var.rsa_bits
}