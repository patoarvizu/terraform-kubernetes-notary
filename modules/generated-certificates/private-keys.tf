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