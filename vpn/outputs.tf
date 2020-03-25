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
