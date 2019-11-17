resource "tls_private_key" "ca" {
  algorithm = "ECDSA"
}

resource "tls_private_key" "server" {
  algorithm = "ECDSA"
}

resource "tls_private_key" "signer" {
  algorithm = "ECDSA"
}