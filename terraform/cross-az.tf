resource "aws_cloudformation_stack" "cross-az"  {
  name = "${var.prefix}-cross-az-stack"
  capabilities = ["CAPABILITY_IAM"]
  parameters = { 
	Vpc = "${module.vpc.vpc_id}" 
        allowUsageAnalytics = "No"
	application = "f5app"
	bigIpModules = "ltm:nominal,apm:nominal"
	costcenter = "f5costcenter"
	customImageId = "OPTIONAL"
	declarationUrl = "none"
	environment = "f5env"
	group = "f5group"
	imageName = "Best1000Mbps"
	instanceType = "m5.xlarge"
	managementSubnetAz1 = "${module.vpc.public_subnets[0]}"
	managementSubnetAz2 = "${module.vpc.public_subnets[1]}"
	ntpServer = "0.pool.ntp.org"
	owner = "f5owner"
	provisionPublicIP = "Yes"
	restrictedSrcAddress = "0.0.0.0/0"
	restrictedSrcAddressApp = "0.0.0.0/0"
	sshKey = "${var.ssh_key}"
	subnet1Az1 = "${module.vpc.public_subnets[3]}"
	subnet1Az2 = "${module.vpc.public_subnets[4]}"
	subnet2Az1 = "${module.vpc.intra_subnets[0]}"
	subnet2Az2= "${module.vpc.intra_subnets[1]}"
	timezone = "UTC"
	}
#  template_url = "https://f5-cft.s3.amazonaws.com/f5-existing-stack-across-az-cluster-payg-3nic-bigip.template"
  template_url = "https://${var.prefix}-cross-az-tf-s3bucket.s3.amazonaws.com/f5-existing-stack-across-az-cluster-payg-3nic-bigip.template"
#  template_body = file("${path.module}/f5-existing-stack-across-az-cluster-payg-3nic-bigip.template")
}
