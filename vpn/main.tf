terraform {
  required_providers {
    bigip = "~> 1.0.0"
  }
}
provider "bigip" {
  address  = "https://${var.address}:${var.port}"
  username = "${var.username}"
  password = "${var.password}"
}
# download rpm
resource "null_resource" "download_as3" {
  provisioner "local-exec" {
    command = "wget ${var.as3_rpm_url}"
  }
}

# install rpm to BIG-IP
resource "null_resource" "install_as3" {
  provisioner "local-exec" {
    command = "./install_as3.sh ${var.address}:${var.port} admin:${var.password} ${var.as3_rpm}"
  }
  depends_on = [null_resource.download_as3]
}

# install rpm to BIG-IP 2
resource "null_resource" "install2_as3" {
  provisioner "local-exec" {
    command = "./install_as3.sh ${var.address2}:${var.port} admin:${var.password} ${var.as3_rpm}"
  }
  depends_on = [null_resource.download_as3]
}

# install rpm to BIG-IP 2
resource "null_resource" "create_connectivit_profile" {
  provisioner "local-exec" {
    command = "./create_connectivity_profile.sh ${var.address}:${var.port} admin:${var.password}"
  }
  depends_on = [null_resource.download_as3]
}

# deploy application using as3
resource "bigip_as3" "vpn" {
  as3_json    = "${file("vpn.json")}"
  tenant_name = "VPN_Example"
  depends_on  = [null_resource.install_as3]
}
