# Example of F5 VPN Automation

This is based on: https://devcentral.f5.com/s/articles/Example-of-F5-VPN-Automation

Inspired by: https://github.com/hashicorp/f5-terraform-consul-sd-webinar

# How to use this repo

# What does it do?

In this example we will use HashiCorp Terraform to create an AWS VPC and deploy a pair of BIG-IP
devices and a backend Ubuntu host.

SSL VPN will be configured to use client certificate authentication (mutual TLS) and
use certificates from HashiCorp Vault.

You will connect using the F5 VPN CLI client (Linux/Raspberry Pi) to verify connectivity.

## Provision Infrastructure

The `terraform` directory has tf files for creating a VPC with BIG-IP in an A/S deployment 
across AZ using the supported CFT from https://github.com/F5Networks/f5-aws-cloudformation/tree/master/supported/failover/across-net/via-api/3nic/existing-stack

## What you'll need

- Linux box (RHEL/CentOS/Debian/Ubuntu)
- Terraform (used to deploy in AWS)
- Docker (used to deploy a local Vault)
- AWS CLI (used to access S3 buckets)

You will also need to accept the T&C of the BIG-IP in the AWS marketplace prior to running this example.

## Steps 
- Clone the repository & change working directory to vault
```
git clone https://github.com/hashicorp/f5-terraform-consul-sd-webinar
cd f5-terraform-consul-sd-webinar/vault/
```

You will need to setup a dev instance of vault that will run in Docker.

You will then configure vault for PKI and configure your environment to use vault.
```
sudo make vault
./setup-pki.sh
source env.sh
```

Next you will need to change into the terraform directory.
```
cd ../vault/
```

- Create Terraform run
- Modify `terraform.tfvars.example` and add a prefix to identify your resources
- Rename `terraform.tfvars.example` to `terraform.tfvars`
An example of `terraform.tvars`:
```
prefix="erchen"
ssh_key="erchen"
aws_region="us-east-1"
````
Next you will to to run the following. 
```
terraform init
terraform plan
terraform apply
```

  - This will create BIG-IP pair and VPC as well as a backend VM
  - This will also seed a `terraform.tfvars` file in the `vpn` directory for use in the next step
  - It may take several minutes for this step to complete.  Verify the BIG-IP is fully up and running (in an HA pair) before proceeding.

After this completes you should see

```
Apply complete! Resources: 39 added, 0 changed, 0 destroyed.

Outputs:

BIG-IP_1 = https://192.0.2.10
BIG-IP_2 = https://192.0.2.110
Backend = 192.0.2.200
Backend_Private = 10.1.10.202
S3Bucket = chen23-cross-az-stack-s3bucket-t7ksuasmgg97
VPN = http://192.0.2.220:80
```

## Configure BIG-IP

Next we will update the AS3 environment.  Deploy a VPN connectivity profile (using iControl REST) and create a VPN configuration using AS3.

Change into the `vpn` directory and run.

```
terraform init
terraform plan
terraform apply
```
You should see the following output (if you need to see this again run `terraform output`

```
BIG-IP_1 = https://192.0.2.10
BIG-IP_2 = https://192.0.2.110
Backend_Test = http://10.1.10.202/txt
Client_DEB = curl --cert ./client.crt --key ./client.key https://192.0.2.220:443/public/download/linux_f5cli.x86_64.deb -k -O -L -J
Client_RPM = curl --cert ./client.crt --key ./client.key https://192.0.2.220:443/public/download/linux_f5cli.x86_64.rpm -k -O -L -J 
Password = [random password]
Username = admin
VPN_Connect = f5fpc -t https://192.0.2.220:443 -x --cert ./client.crt --key ./client.key -u user -p pass --start
```
If you do not have the F5 VPN CLI client installed you can use the provided curl commands to download the appropriate package.

You will want to verify that BIG-IP #1 is the "Active" device.

You can do this either via SSH (using key or password) or via GUI (password).

Once you have verified that it is active you should be able to run the following command to connect.

```
# note the use of HTTPS
f5fpc -t https://192.0.2.220 -x --cert ./client.crt --key ./client.key -u user -p pass --start
```
You can then run the info command to verify your connection.

```
$ f5fpc --info
Connection Status: session established
Favorites Information:
______________________
fav-Id   fav-Type  fav-Status       fav-Name
326      vpn        established     /VPN_App/accessProfile-erchenNetworkAccess


Favorites Extended Info:
________________________
Fav-Id: 326  Fav-Name: /VPN_App/accessProfile-erchenNetworkAccess
Tunnel Port:                    443
Tunnel Protocol:                TCP
Tunnel Security Protocol:       TLSv1.2
Tunnel Cipher Strength:         128
Tunnel Hash Algorithm:          AEAD
Tunnel Cipher Algorithm:        AESGCM(128)
Tunnel PKI Algorithm:           ECDH
Tunnel Client IPv4 Address:     192.168.100.10
Tunnel Client IPv6 Address:
Tunnel Server IPv4 Address:     1.1.1.1
Tunnel Server IPv6 Address:
Tunnel GZip Compression:        Disabled
Tunnel Bytes In:                2075
Tunnel Bytes In (Low):          196
Tunnel Bytes Out:               3192
Tunnel Bytes Out (Low):         610
```
Once connected you should be able to connect to the backend VM.

```
$ curl http://10.1.10.202/txt
___ ___   ___                    _
| __| __| |   \ ___ _ __  ___    /_\  _ __ _ __
| _||__ \ | |) / -_) '  \/ _ \  / _ \| '_ \ '_ \
|_| |___/ |___/\___|_|_|_\___/ /_/ \_\ .__/ .__/
                                      |_|  |_|
================================================
      Node Name: Example of F5 VPN Automation
     Short Name: ip-10-1-10-202
      Server IP: 10.1.10.202
    Server Port: 80
      Client IP: 10.1.10.12
    Client Port: 51050
```