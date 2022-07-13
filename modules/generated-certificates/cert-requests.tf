resource "tls_cert_request" "server" {
  private_key_pem = tls_private_key.server.private_key_pem
  subject {
    common_name = "notary-server"
  }
  dns_names = ["notary-server"]
}

resource "tls_cert_request" "signer" {
  private_key_pem = tls_private_key.signer.private_key_pem
  subject {
    common_name = "notary-signer"
  }
  dns_names = ["notary-signer"]
}