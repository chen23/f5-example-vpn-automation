data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "backend" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  subnet_id = "${module.vpc.public_subnets[3]}"
  vpc_security_group_ids = ["${aws_security_group.backend.id}"]
  key_name = "${var.ssh_key}"
  user_data = <<-EOF
#!/bin/bash
sleep 30
snap install docker
systemctl enable snap.docker.dockerd
systemctl start snap.docker.dockerd
sleep 30
docker run -d -p 80:80 --net host -e F5DEMO_APP=website -e F5DEMO_NODENAME="Example of F5 VPN Automation" --restart always --name f5demoapp f5devcentral/f5-demo-httpd:nginx
              EOF

  tags = {
	Name = "${var.prefix}-backend"
  }
}
