resource "tls_private_key" "ca" {
  algorithm = var.private_key_algorithm
}

resource "tls_private_key" "server" {
  algorithm = var.private_key_algorithm
}

resource "tls_private_key" "signer" {
  algorithm = var.private_key_algorithm
}