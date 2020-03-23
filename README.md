# Example of F5 VPN Automation

This is based on: https://devcentral.f5.com/s/articles/Example-of-F5-VPN-Automation

Inspired by: https://github.com/hashicorp/f5-terraform-consul-sd-webinar

# How to use this repo

## Provision Infrastructure

The `terraform` directory has tf files for creating a VPC with BIG-IP in an A/S deployment 
across AZ using the supported CFT from https://github.com/F5Networks/f5-aws-cloudformation/tree/master/supported/failover/across-net/via-api/3nic/existing-stack

## Steps

## Steps 
- Clone the repository & change working directory to terraform
```
git clone https://github.com/hashicorp/f5-terraform-consul-sd-webinar
cd f5-terraform-consul-sd-webinar/terraform/
```
- Create Terraform run
- Modify `terraform.tfvars.example` and add a prefix to identify your resources
- Rename `terraform.tfvars.example` to `terraform.tfvars`

```
terraform init
terraform plan
terraform apply
```

  - This will create BIG-IP pair and VPC
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

