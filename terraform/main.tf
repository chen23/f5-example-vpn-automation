# Generate a tfvars file for AS3 installation
data "template_file" "tfvars" {
  template = "${file("../vpn/terraform.tfvars.example")}"
  vars = {
    addr     = "${aws_cloudformation_stack.cross-az.outputs.Bigip1ManagementEipAddress}",
    addr2     = "${aws_cloudformation_stack.cross-az.outputs.Bigip2ManagementEipAddress}",
    self     = "${aws_cloudformation_stack.cross-az.outputs.Bigip1InternalInterfacePrivateIp}",
    self2     = "${aws_cloudformation_stack.cross-az.outputs.Bigip2InternalInterfacePrivateIp}",
    eni     = "${aws_cloudformation_stack.cross-az.outputs.Bigip1InternalInterface}",
    eni2     = "${aws_cloudformation_stack.cross-az.outputs.Bigip2InternalInterface}",
    vip       = "${aws_cloudformation_stack.cross-az.outputs.Bigip1VipPrivateIp}",
    port     = "443",
    username = "admin"
  }
}

data "template_file" "json" {
  template = "${file("../vpn/vpn.json.example")}"
  vars = {
    vip       = "${aws_cloudformation_stack.cross-az.outputs.Bigip1VipPrivateIp}"
  }
}


resource "local_file" "tfvars" {
  content  = "${data.template_file.tfvars.rendered}"
  filename = "../vpn/terraform.tfvars"
}
resource "local_file" "json" {
  content  = "${data.template_file.json.rendered}"
  filename = "../vpn/vpn.json"
}
