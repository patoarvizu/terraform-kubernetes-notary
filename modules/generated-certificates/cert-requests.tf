resource "tls_cert_request" "server" {
  key_algorithm = tls_private_key.server.algorithm
  private_key_pem = tls_private_key.server.private_key_pem
  subject {
    common_name = "notary-server"
  }
  dns_names = concat(["notary-server"], var.subject_alternative_names_server)
}

resource "tls_cert_request" "signer" {
  key_algorithm = tls_private_key.signer.algorithm
  private_key_pem = tls_private_key.signer.private_key_pem
  subject {
    common_name = "notary-signer"
  }
  dns_names = concat(["notary-signer"], var.subject_alternative_names_signer)
}