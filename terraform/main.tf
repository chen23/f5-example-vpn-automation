# S3 bucket for CFT / Profile

resource "aws_s3_bucket" "tf_s3_bucket" {
  bucket = "${var.prefix}-cross-az-tf-s3bucket"
}

# customized CFT template (private)

resource "aws_s3_bucket_object" "custom_cft" {
  bucket = "${var.prefix}-cross-az-tf-s3bucket"
  key = "f5-existing-stack-across-az-cluster-payg-3nic-bigip.template"
  source = "f5-existing-stack-across-az-cluster-payg-3nic-bigip.template"
}

# APM profile (public)

resource "aws_s3_bucket_object" "custom_profile" {
  bucket = "${var.prefix}-cross-az-tf-s3bucket"
  key = "profile_Common_erchen_ap.conf.tar"
  source = "profile_Common_erchen_ap.conf.tar"
  acl = "public-read"
}


# Generate a tfvars file for AS3 installation
data "template_file" "tfvars" {
  template = "${file("../vpn/terraform.tfvars.example")}"
  vars = {
    addr     = "${aws_cloudformation_stack.cross-az.outputs.Bigip1ManagementEipAddress}",
    addr2     = "${aws_cloudformation_stack.cross-az.outputs.Bigip2ManagementEipAddress}",
    self     = "${aws_cloudformation_stack.cross-az.outputs.Bigip1ExternalInterfacePrivateIp}",
    self2     = "${aws_cloudformation_stack.cross-az.outputs.Bigip2ExternalInterfacePrivateIp}",
    eni     = "${aws_cloudformation_stack.cross-az.outputs.Bigip1InternalInterface}",
    eni2     = "${aws_cloudformation_stack.cross-az.outputs.Bigip2InternalInterface}",
    vip       = "${aws_cloudformation_stack.cross-az.outputs.Bigip1VipPrivateIp}",
    vip2       = "${aws_cloudformation_stack.cross-az.outputs.Bigip2VipPrivateIp}",
    port     = "443",
    username = "admin"
  }
}

data "template_file" "json" {
  template = "${file("../vpn/vpn.json.example")}"
  vars = {
    vip       = "${aws_cloudformation_stack.cross-az.outputs.Bigip1VipPrivateIp}",
    vip2       = "${aws_cloudformation_stack.cross-az.outputs.Bigip2VipPrivateIp}",
    certificate = "${replace(vault_pki_secret_backend_cert.vpn_cert.certificate,"\n","\\n")}",
    private_key = "${replace(vault_pki_secret_backend_cert.vpn_cert.private_key,"\n","\\n")}",
    ca_certificate = "${replace(vault_pki_secret_backend_cert.vpn_cert.issuing_ca,"\n","\\n")}",
    bucket = "${var.prefix}-cross-az-tf-s3bucket"
  }
}

data "template_file" "cfe" {
  template = "${file("../vpn/cfe.json.example")}"
  vars = {
    prefix = "${var.prefix}"
    self     = "${aws_cloudformation_stack.cross-az.outputs.Bigip1ExternalInterfacePrivateIp}",
    self2     = "${aws_cloudformation_stack.cross-az.outputs.Bigip2ExternalInterfacePrivateIp}"
  }
}
resource "local_file" "cfe" {
  content  = "${data.template_file.cfe.rendered}"
  filename = "../vpn/cfe.json"
}

resource "local_file" "tfvars" {
  content  = "${data.template_file.tfvars.rendered}"
  filename = "../vpn/terraform.tfvars"
}
resource "local_file" "json" {
  content  = "${data.template_file.json.rendered}"
  filename = "../vpn/vpn.json"
}

resource "local_file" "client_cert" {
  content = "${vault_pki_secret_backend_cert.client_cert.certificate}"
  filename = "../vpn/client.crt"
}

resource "local_file" "client_key" {
  content = "${vault_pki_secret_backend_cert.client_cert.private_key}"
  filename = "../vpn/client.key"
}


resource "null_resource" "wait_for_creds" {
  provisioner "local-exec" {
    command = "./get_credentials.sh ${aws_cloudformation_stack.cross-az.outputs.S3Bucket}"
  }

}