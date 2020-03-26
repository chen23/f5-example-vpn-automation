variable "address" {}
variable "address2" {}
variable "backend" {}
variable "port" {}
variable "username" {}
variable "password" {}
variable "vpn" {}
variable "as3_rpm" {
  default = "f5-appsvcs-3.18.0-4.noarch.rpm"
}
variable "as3_rpm_url" {
  default = "https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.18.0/f5-appsvcs-3.18.0-4.noarch.rpm"
}
