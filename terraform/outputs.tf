output "BIG-IP_1" {
  value = "${aws_cloudformation_stack.cross-az.outputs.Bigip1Url}"
}
output "BIG-IP_2" {
  value = "${aws_cloudformation_stack.cross-az.outputs.Bigip2Url}"
}
output "VPN" {
  value = "${aws_cloudformation_stack.cross-az.outputs.Bigip1VipEipAddress}"
}
output "S3Bucket" {
  value = "${aws_cloudformation_stack.cross-az.outputs.S3Bucket}"
}
output "Backend" {
  value = "${aws_instance.backend.public_ip}"
}
output "Backend_Private" {
  value = "${aws_instance.backend.private_ip}"
}
