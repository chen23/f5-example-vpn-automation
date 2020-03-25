provider "vault" {


}
resource "vault_pki_secret_backend_cert" "vpn_cert" {

  backend = "pki_int"
  name = "example-dot-com"

  common_name = "vpn.example.com"
}

resource "vault_pki_secret_backend_cert" "client_cert" {

  backend = "pki_int"
  name = "example-dot-com"

  common_name = "client.vpn.example.com"
}