# Terraform

## Introduction
This terraform cookbook create a basic VPC environment on AWS.
You can custom `variables.tf` file.

This cookbook is based on terraform `0.7.4`.

## Includes
  * VPC
  * Internet Gateway
  * 2 AZ
  * Custom DHCP
  * 2 Subnets : private, public, with routes tables
  * 2 NAT Gateway
  * 1 RDS subnets

## Commands
If you just want to see what append :
```bash
terraform plan -var 'access_key=XXXX' -var 'secret_key=XXXXX' -state='states/myfilesofstates.ireland'
```

If you want to create the stack :
```bash
terraform apply -var 'access_key=XXXX' -var 'secret_key=XXXXX' -state='states/myfilesofstates.ireland'
```

# Links
  * https://charity.wtf/2016/03/30/terraform-vpc-and-why-you-want-a-tfstate-file-per-env/