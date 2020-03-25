# Example of F5 VPN Automation

This is based on: https://devcentral.f5.com/s/articles/Example-of-F5-VPN-Automation

Inspired by: https://github.com/hashicorp/f5-terraform-consul-sd-webinar

# How to use this repo

## Provision Infrastructure

The `terraform` directory has tf files for creating a VPC with BIG-IP in an A/S deployment 
across AZ using the supported CFT from https://github.com/F5Networks/f5-aws-cloudformation/tree/master/supported/failover/across-net/via-api/3nic/existing-stack

## What you'll need

- Linux box (RHEL/CentOS/Debian/Ubuntu)
- Terraform
- Docker
- AWS CLI
- F5 VPN CLI

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

## Configure BIG-IP

Next we will update the AS3 environment.  Deploy a VPN connectivity profile (using iControl REST) and create a VPN configuration using AS3.

Change into the `vpn` directory and run.

```
terraform init
terraform plan
terraform apply
```

