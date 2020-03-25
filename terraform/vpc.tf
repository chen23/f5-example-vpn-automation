provider "aws" {
  version = "~> 2.0"
  region  = "${var.aws_region}"
}
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> v2.0"

  name = "${var.prefix}-f5-vpn-vpc"
  cidr = "10.1.0.0/16"

  azs            = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  public_subnets = ["10.1.1.0/24","10.1.2.0/24","10.1.3.0/24","10.1.10.0/24","10.1.11.0/24","10.1.12.0/24"]

  intra_subnets = ["10.1.20.0/24","10.1.21.0/24","10.1.22.0/24"]
  intra_route_table_tags = {
    f5_cloud_failover_label = "${var.prefix}-cross-az-stack"
    f5_self_ips = "${aws_cloudformation_stack.cross-az.outputs.Bigip1ExternalInterfacePrivateIp},${aws_cloudformation_stack.cross-az.outputs.Bigip2ExternalInterfacePrivateIp}"
}

  public_route_table_tags = {
    f5_cloud_failover_label = "${var.prefix}-cross-az-stack"
    f5_self_ips = "${aws_cloudformation_stack.cross-az.outputs.Bigip1ExternalInterfacePrivateIp},${aws_cloudformation_stack.cross-az.outputs.Bigip2ExternalInterfacePrivateIp}"
}

  enable_nat_gateway = false
  enable_dns_hostnames = true

  tags = {
#    Environment = "F5"
#    Name = "${var.prefix}-f5-vpn-vpc"
  }
}

#resource "aws_route_table" "intra_rt" {
#  vpc_id = "${module.vpc.vpc_id}"
#  tags = {
#    Name = "${var.prefix}-f5-vpn-vpc-intra_rt"
#    f5_cloud_failover_label = "${var.prefix}-cross-az-stack"
#    f5_self_ips = "${aws_cloudformation_stack.cross-az.outputs.Bigip1InternalInterfacePrivateIp},${aws_cloudformation_stack.cross-az.outputs.Bigip2InternalInterfacePrivateIp}"
#  }
#}
resource "aws_route" "outbound_intra_route" {
route_table_id  = "${module.vpc.intra_route_table_ids[0]}"
destination_cidr_block = "0.0.0.0/0"
network_interface_id = "${aws_cloudformation_stack.cross-az.outputs.Bigip1InternalInterface}"
}

resource "aws_route" "vpn_intra_route" {
route_table_id  = "${module.vpc.intra_route_table_ids[0]}"
destination_cidr_block = "192.168.100.0/24"
network_interface_id = "${aws_cloudformation_stack.cross-az.outputs.Bigip1InternalInterface}"
}

resource "aws_route" "vpn_public_route" {
route_table_id  = "${module.vpc.public_route_table_ids[0]}"
destination_cidr_block = "192.168.100.0/24"
network_interface_id = "${aws_cloudformation_stack.cross-az.outputs.Bigip1InternalInterface}"
}


#resource "aws_eip" "f5" {
#  instance = "${aws_instance.f5.id}"
#  vpc      = true
#}

resource "aws_security_group" "f5" {
  name   = "${var.prefix}-f5"
  vpc_id = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "nginx" {
  name   = "${var.prefix}-nginx"
  vpc_id = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 8300
    to_port     = 8300
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "backend" {
  name   = "${var.prefix}-backend"
  vpc_id = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
