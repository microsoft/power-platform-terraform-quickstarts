# Initial Bootstrap Configuration

This directory contains scripts to bootstrap the initial configuration of the Entra tenant, Azure subscription, and GitHub workflows.  Once this initial configuration is complete, the rest of the resources can be deployed using GitHub Actions workflows.  While this configuration has been automated to ease the process of getting started with a trial tenant, it is not recommended to use this configuration as-is in existing production environments.  Review the scripts and modify them to meet your own needs.

## Resources Created

The following resources are created by the `bootstrap.sh` script:

### Terraform State Backend

Terraform can use [Azure Blob Storage as a backend for storing the state of the infrastructure](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm).  This allows multiple users and/or deployment pipelines to collaborate on the same infrastructure without having to share a local copy of the state file.  The `bootstrap.sh` script creates the following resources to support the terraform state backend:

* Azure resource group for terraform state
* Azure storage account for terraform state
* Azure blob storage container for terraform state (public access disabled)
* Azure Defender for Storage enabled on the storage account

### Identity and Access Management

The Terraform Provider for Power Platform recommends to use a service principal for managing Power Platform resources.  To manage Power Platform as an administrator, the service principal needs to be [granted admin role permissions](https://learn.microsoft.com/en-us/power-platform/admin/powerplatform-api-create-service-principal#registering-an-admin-management-application) and needs to be [assigned permissions in the Power Platform API](https://learn.microsoft.com/en-us/power-platform/admin/programmability-permission-reference).  The `bootstrap.sh` script creates the following resources to support the service principal:

* An app registration in Entra Id
* A service principal linked to the app registration
* Permissions for the service principal
  * Licensing.BillingPolicies.ReadWrite
  * Licensing.BillingPolicies.Read
  * AppManagement.ApplicationPackages.Install
  * AppManagement.ApplicationPackages.Read
* Power Platform Admin role grant to the service principal
* Azure Data Access Blob Contributor role grant to the service principal

### GitHub Actions Workflow configuration via Secrets and Variables

In order to use the GitHub Actions workflows, the following secrets and variables need to be configured in the GitHub repository:

* PPADMIN_CLIENT_SECRET with the service principal credentials
* PPADMIN_CLIENT_ID with the service principal client ID
* PPADMIN_TENANT_ID with the tenant ID
* TF_STATE_STORAGE_ACCOUNT_NAME with the storage account name for terraform state

## Prerequisites

It is highly recommended that you use the Dev Container to run the bootstrap script. The following tooling is pre-installed in the Dev Container:

* [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/)
* [Terraform CLI](https://developer.hashicorp.com/terraform/cli)
* [GitHub CLI](https://cli.github.com/)

## Usage

This script is intended to be run locally by a user with `Owner` permissions in the Azure subscription, `Global Administrator` or `User Administrator` permissions in the Azure AD tenant, and `Admin` permissions in the GitHub repository.

```bash
./bootstrap.sh --subscription_id 6bcd4321-fcba-0987-6543-210fedcba987 --location eastus
```

## Outputs

The `bootstrap.sh` writes its outputs to a `backend.tfvars` file in the `tenent-configuration` directory.  The `backend.tfvars` file is used by the `tenant-configuration` terraform configuration to configure the backend for the terraform state.

## Configuring Local Environment

After the bootstrap script has completed, you optionally can run the `set-local-env.sh` script to configure your local environment to use the terraform state backend.  This sets local environment variables used by the `terraform` CLI to configure the backend.  If you do not intend to use the `terraform` CLI locally (i.e. you only plan to use GitHub Actions workflows), you can skip this step.

```bash
source ./set-local-env.sh
```