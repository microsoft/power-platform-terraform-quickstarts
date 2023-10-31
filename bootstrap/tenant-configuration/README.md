# Configure Tenant Settings

This document describes how to configure tenant level settings and resources needed to apply other terraform modules that create power platform and azure resources.

## Prerequisites

* You have already completed the [bootstrap](../bootstrap/README.md) steps
* You are logged into the Azure CLI with credentials that have:
    * Owner role on the Azure subscription
    * Global Administrator or User Administrator role on the Azure AD tenant
* You are logged into GitHub with credentials that have admin access to the repository

## Resources Created

* An app registration and service principal for managaing Power Platform resources
* Permissions for the service principal
  * Licensing.BillingPolicies.ReadWrite
  * Licensing.BillingPolicies.Read
  * AppManagement.ApplicationPackages.Install
  * AppManagement.ApplicationPackages.Read
* [Power Platform Admin role grant to the service principal](https://learn.microsoft.com/en-us/power-platform/admin/powerplatform-api-create-service-principal#registering-an-admin-management-application)
* GitHub secrets and variables
  * PPADMIN_CLIENT_SECRET with the service principal credentials
  * PPADMIN_CLIENT_ID with the service principal client ID
  * PPADMIN_TENANT_ID with the tenant ID
  * TF_STATE_STORAGE_ACCOUNT_NAME with the storage account name for terraform state

## Usage

```bash
gh auth login

# Call terraform init with backend.tfvars as backend config file
terraform init -backend-config=../../backend.tfvars

# Run terraform apply and get the output values into variables
terraform apply -var-file=../../backend.tfvars
```