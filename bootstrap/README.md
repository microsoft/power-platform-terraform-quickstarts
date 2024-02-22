# Initial Bootstrap Configuration

This directory contains scripts to bootstrap the initial configuration for using the Power Platform Terraform Provider and **Quickstart Examples**. You have following boostrap options to choose from:
 * Having terraform state saved locally (simlpified version)
 * Having terraform state saved in Azure Storage Account (advanced version required for Azure Subscription)

More informatios regarding terraform state can be found here: 
 - <https://developer.hashicorp.com/terraform/language/state>
 - <https://learn.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli>

## Resources Created

The following resources are created by the `bootstrap.sh` script:

### Identity and Access Management

This is a list of all the required permissions for the service principal. The service principal is used to manage Power Platform resources.
An API for this app registration will also be exposed in order to use [Azure CLI as authentication harness](https://github.com/microsoft/terraform-provider-power-platform/blob/main/docs/cli.md) for you terraform scripts.

* An app registration and service principal for managing Power Platform resources
* Dynamics CRM
  * user_impersonation
* Power App Service
  * User
* Permissions for the service principal
  * AppManagement.ApplicationPackages.Install
  * AppManagement.ApplicationPackages.Read
  * Licensing.BillingPolicies.Read
  * Licensing.BillingPolicies.ReadWrite
* [Power Platform Admin role grant to the service principal](https://learn.microsoft.com/en-us/power-platform/admin/powerplatform-api-create-service-principal#registering-an-admin-management-application)
* Azure Data Access Blob Contributor role grant to the service principal

### Terraform State Backend in Azure Storage Account (advanced version)

* Azure resource group for terraform state
* Azure storage account for terraform state
* Azure blob storage container for terraform state (public access disabled)
* Azure Defender for Storage enabled on the storage account

## Prerequisites

It is highly recommended that you use the Dev Container to run the bootstrap script. The following tooling is pre-installed in the Dev Container:

* [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/)
* [Terraform CLI](https://developer.hashicorp.com/terraform/cli)
* [GitHub CLI](https://cli.github.com/)

## Usage

The `bootstrap.sh` script is intended to be run locally by a user with `Owner` permissions in the Azure subscription, `Global Administrator` or `User Administrator` permissions in the Azure AD tenant.


- Simple version with local Terraform state:
```bash
./bootstrap/bootstrap.sh
```

- Advanced version with Azure Storage Account as Terraform state backend:
```bash
./bootstrap/bootstrap.sh --subscription_id <GUID> --location eastus
```

> **Note**: Remeber that the administrator has to grand permsissions to the newly created service principal. The service principal will be created in the same tenant as the subscription.

## Outputs (Advanced version only)

The `bootstrap.sh` [bootstrap.sh](/bootstrap/bootstrap.sh) writes its outputs to a `backend.tfvars` file in the [tenant-configuration](/bootstrap/tenant-configuration/) directory.  The `backend.tfvars` file is used by the [tenant-configuration](/bootstrap/tenant-configuration/) terraform configuration to configure the backend for the terraform state.

After executing [bootstrap.sh](/bootstrap/bootstrap.sh) you can follow instructions in the [tenant-configuration/README.md](/bootstrap/tenant-configuration/README.md) to configure the tenant settings.
