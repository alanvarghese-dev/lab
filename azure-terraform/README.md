# Azure Infrastructure Provisioning with Terraform

## Overview

This project provisions and manages foundational Azure infrastructure using Terraform and the AzureRM provider.

The objective is to practice Infrastructure as Code (IaC), repeatable cloud deployments, networking, and version-controlled infrastructure management in a DevPod development environment.

## Architecture

The project provisions the following Azure resources:

- Azure Resource Group
- Azure Virtual Network
- Application Subnet
- Network Security Group (NSG)
- Subnet-to-NSG Association

### Network Configuration

| Component | Name | Configuration |
|-----------|------|---------------|
| Resource Group | rg-terraform-lab | Central India |
| Virtual Network | vnet-terraform-lab | 10.10.0.0/16 |
| Application Subnet | snet-app | 10.10.1.0/24 |
| Network Security Group | nsg-terraform-lab | Associated with application subnet |

## Technology Stack

- Azure: Cloud infrastructure provider
- Terraform: Infrastructure provisioning and lifecycle management
- AzureRM Provider: Terraform integration with Azure
- Azure CLI: Azure account and resource verification
- mise: Development tool version management
- DevPod: Isolated development environment
- Git: Infrastructure version control

## Project Structure

azure-terraform/
├── .gitignore
├── .env.azure
├── mise.toml
├── README.md
└── terraform/
    ├── versions.tf
    ├── providers.tf
    ├── main.tf
    ├── variables.tf
    └── outputs.tf

Note: .env.azure is a local credentials file and must never be committed to Git.

## Prerequisites

- An Azure subscription
- A Microsoft Entra application registration and service principal
- Appropriate Azure permissions to create the required resources
- Terraform installed
- Azure CLI installed
- mise configured in the development environment
- A DevPod development environment

## Authentication

Local Terraform authentication uses a Microsoft Entra service principal.

The AzureRM provider reads credentials from the following environment variables:

- ARM_CLIENT_ID
- ARM_CLIENT_SECRET
- ARM_TENANT_ID
- ARM_SUBSCRIPTION_ID

Credentials are loaded locally from .env.azure.

Example .env.azure format:

export ARM_CLIENT_ID="YOUR_APPLICATION_CLIENT_ID"
export ARM_CLIENT_SECRET="YOUR_CLIENT_SECRET_VALUE"
export ARM_TENANT_ID="YOUR_TENANT_ID"
export ARM_SUBSCRIPTION_ID="YOUR_SUBSCRIPTION_ID"

Replace the placeholders locally with your actual credentials.

Never commit .env.azure, share the client secret, or hardcode credentials in Terraform configuration.

Load the environment variables from the project root:

set -a
source .env.azure
set +a

Ensure .env.azure is excluded by .gitignore.

## Deployment

Run Terraform commands from the terraform/ directory.

### 1. Initialize Terraform

terraform init

This downloads the required providers and initializes the Terraform working directory.

### 2. Format the Configuration

terraform fmt -recursive

This formats Terraform configuration files consistently.

### 3. Validate the Configuration

terraform validate

This checks the Terraform configuration for syntax and structural errors.

### 4. Preview Infrastructure Changes

terraform plan

Review the proposed changes before applying them.

### 5. Deploy the Infrastructure

terraform apply

Review the proposed changes and enter yes when prompted to approve the deployment.

## Verification

List resources managed by Terraform:

terraform state list

Expected resource addresses:

azurerm_resource_group.lab
azurerm_virtual_network.lab
azurerm_subnet.app
azurerm_network_security_group.lab
azurerm_subnet_network_security_group_association.app

Display configured outputs:

terraform output

Inspect a specific resource:

terraform state show azurerm_resource_group.lab

You can also verify the resources in the Azure Portal under:

Resource groups → rg-terraform-lab

Confirm that the resource group, virtual network, subnet, and network security group exist in the intended Azure subscription.

## Terraform State Management

Terraform state tracks the relationship between the configuration and the deployed Azure resources.

This learning project uses local Terraform state by default.

Important precautions:

- Never commit terraform.tfstate or its backup files.
- Never commit saved Terraform plan files.
- Keep the .terraform/ directory excluded from Git.
- Protect state files because they can contain sensitive information.
- Back up state before making significant changes.
- Use a secured Azure Storage backend with appropriate access controls and state locking when collaborating or building a production workflow.

## Security Considerations

- Store service principal credentials locally and securely.
- Exclude .env.azure from version control.
- Avoid printing secrets in terminal output or CI logs.
- Use least-privilege access wherever practical.
- Avoid opening inbound network access unless required.
- Rotate or revoke credentials when necessary.
- Prefer GitHub Actions with Azure workload identity federation (OIDC) for future CI/CD automation instead of storing a long-lived client secret.
- Protect Terraform state and any generated plan files.

## Git Hygiene

Before committing the project, verify which files Git will track:

git status --short

Check that the credentials file is ignored:

git check-ignore -v .env.azure

The repository should contain Terraform configuration, documentation, and other non-sensitive project files.

Do not commit:

- .env.azure
- Client secrets
- terraform.tfstate
- terraform.tfstate.backup
- .terraform/
- Saved Terraform plan files
- Local secret or override files

If this project is part of a larger lab repository, retain the existing parent Git repository rather than creating an unnecessary nested Git repository.

## Cleanup

When the lab is no longer required, inspect the proposed destruction plan:

terraform plan -destroy

If the plan contains only resources you intend to remove, execute:

terraform destroy

Review the plan carefully and confirm when prompted.

WARNING: Destroying resources is irreversible. Back up anything you need and do not run this against shared or production infrastructure.

## Future Improvements

- Configure a remote Terraform state backend in Azure Storage.
- Add GitHub Actions for Terraform formatting, validation, and planning.
- Configure Azure OIDC authentication for CI/CD.
- Introduce reusable Terraform modules.
- Introduce separate development and production environments.
- Add automated policy and security checks.
- Improve IAM permissions and credential management.
- Add automated infrastructure testing.

## Learning Outcomes

This project demonstrates practical experience with:

- Infrastructure as Code using Terraform
- Azure service principal authentication
- Azure resource provisioning
- Virtual network and subnet design
- Network Security Group association
- Terraform variables and outputs
- Terraform state and lifecycle management
- Git-based infrastructure workflows
- Cloud credential hygiene
- Infrastructure deployment and cleanup

## Project Status

The initial resource group has been provisioned successfully using Terraform.

The project is intended to expand into a reusable and secure Azure infrastructure provisioning workflow, with networking, documentation, and future CI/CD automation.
