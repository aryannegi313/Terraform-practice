# Terraform Practice

This repository is a hands-on Terraform learning project that demonstrates infrastructure provisioning on AWS and basic automation with Ansible.

## What this project does

The main Terraform configuration in [main_project](main_project) provisions:
- a VPC, subnet, internet gateway, and route table
- a security group allowing HTTP and SSH access
- an Amazon Linux EC2 instance
- an SSH key pair through the reusable module in [main_project/modules/ssh-key](main_project/modules/ssh-key)
- an Ansible inventory file that points to the newly created instance

The Ansible playbook in [ansible/setup_server.yml](ansible/setup_server.yml) installs and starts Nginx on the provisioned server.

## Project structure

- [main_project](main_project): core Terraform configuration for the EC2 instance and networking
- [main_project/modules/ssh-key](main_project/modules/ssh-key): reusable module for creating an SSH key
- [ansible](ansible): inventory template and server setup playbook
- [state_file_management](state_file_management): Terraform configuration for S3 remote state storage and DynamoDB state locking
- [aws](aws): AWS CLI v2 installer bundle

## Prerequisites

Before running the infrastructure:
- Terraform 1.2 or newer
- AWS CLI configured with valid credentials
- Ansible installed if you want to configure the server after provisioning
- Permission to create EC2, VPC, S3, and DynamoDB resources in your AWS account

## Getting started

1. Change into [main_project](main_project)
2. Initialize Terraform:
   ```bash
   terraform init
   ```
3. Review the planned changes:
   ```bash
   terraform plan
   ```
4. Apply the configuration:
   ```bash
   terraform apply
   ```

Terraform will create the AWS resources and generate an inventory file for Ansible at [ansible/inventory.ini](ansible/inventory.ini).

## Ansible deployment

After the infrastructure is created, run:

```bash
ansible-playbook -i ansible/inventory.ini ansible/setup_server.yml
```

This installs Nginx and prepares the server with a simple web page.

## Remote state management

The [state_file_management](state_file_management) directory creates an S3 bucket and DynamoDB table for Terraform remote state and locking. This is useful for shared or production-style workflows and avoids keeping state locally.

## Notes

- The example uses a specific AWS region and CIDR ranges, so you may want to adjust them for your environment.
- The security group rules are currently set up for a specific SSH source IP, which should be updated if needed.
- The generated private key path is written to the Terraform output and used by Ansible.