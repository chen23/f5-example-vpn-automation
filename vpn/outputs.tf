output "BIG-IP_1" {
  value = "https://${var.address}"
}
output "BIG-IP_2" {
  value = "https://${var.address2}"
}
output "Username" {
  value = "${var.username}"
}
output "Password" {
  value = "${var.password}"
}
output "VPN_Connect" {
  value = "f5fpc -t ${var.vpn} -x --cert ./client.crt --key ./client.key -u user -p pass --start"
}
output "Client_RPM" {
  value = "curl --cert ./client.crt --key ./client.key ${var.vpn}/public/download/linux_f5cli.x86_64.rpm -k -O -L -J"
}
output "Client_DEB" {
  value = "curl --cert ./client.crt --key ./client.key ${var.vpn}/public/download/linux_f5cli.x86_64.deb -k -O -L -J"
}
output "Backend_Test" {
  value = "http://${var.backend}/txt"
}
