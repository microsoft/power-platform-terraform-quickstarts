# Initial Bootstrap Configuration

This directory contains scripts to bootstrap the initial configuration of the Entra tenant, Azure subscription, and GitHub workflows.  Once this initial configuration is complete, the rest of the resources can be deployed using GitHub Actions workflows.  While this configuration has been automated to ease the process of getting started, it is not recommended to use this configuration as-is in existing production environments.  Review the scripts and modify them to meet your own needs.

## Resources Created

The following resources are created by the `bootstrap.sh` script:

### Terraform State Backend

* Azure resource group for terraform state
* Azure storage account for terraform state
* Azure blob storage container for terraform state (public access disabled)
* Azure Defender for Storage enabled on the storage account

### Identity and Access Management

* An app registration and service principal for managing Power Platform resources
* Permissions for the service principal
  * Licensing.BillingPolicies.ReadWrite
  * Licensing.BillingPolicies.Read
  * AppManagement.ApplicationPackages.Install
  * AppManagement.ApplicationPackages.Read
* [Power Platform Admin role grant to the service principal](https://learn.microsoft.com/en-us/power-platform/admin/powerplatform-api-create-service-principal#registering-an-admin-management-application)
* Azure Data Access Blob Contributor role grant to the service principal

### GitHub Actions Workflow configuration via Secrets and Variables

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
./bootstrap.sh --subscription_id <GUID> --location eastus --github_repo commercial-software-engineering/power-platform-tenant-quickstart --github_pat_token <TOKEN>
```

## Outputs

The `bootstrap.sh` [bootstrap.sh](/bootstrap/bootstrap.sh) writes its outputs to a `backend.tfvars` file in the [tenant-configuration](/bootstrap/tenant-configuration/) directory.  The `backend.tfvars` file is used by the [tenant-configuration](/bootstrap/tenant-configuration/) terraform configuration to configure the backend for the terraform state.

After excuting [bootstrap.sh](/bootstrap/bootstrap.sh) you can follow instructions in the [tenant-configuration/README.md](/bootstrap/tenant-configuration/README.md) to configure the tenant settings.