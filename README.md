# Power Platform Terraform Quickstarts

This repository contains example terraform modules that can be used to quickly deploy Power Platform environments and other Azure resources.  The modules are intended to demonstrate some common scenarios where managing Power Platform resources along side Azure, Entra, or other resources can be facilitated with the [Terraform Provider for Power Platform](https://github.com/microsoft/terraform-provider-power-platform).  The modules are examples and are not intended to be used in production environments without modification.

This repository contains scripts quickly build out a new tenant and configure it to allow you to deploy and manage Power Platform environments along side other Azure resources. The scripts assume that you are starting with a completely new tenant with an empty Azure subscription.  This is a template repository that is intended to let you fork and customize the Power Platform/Azure resources to accomodate your own needs.

## Prerequisites

* Microsoft Tenant that you have `global admin` or `user administrator` permissions in
* Azure subscription in the tenant that you have `owner` permissions in
* A fork of this GitHub repository that you have `admin` permissions in

### Tooling

The following tooling is pre-installed in the Dev Container and it is highly recommended that you use the Dev Container to run the scripts and terraform modules in this repository:

* [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/)
* [Terraform CLI](https://developer.hashicorp.com/terraform/cli)
* [GitHub CLI](https://cli.github.com/)

### Terraform Providers

The following terraform providers are used in this repository:
* [PowerPlatform](https://github.com/microsoft/terraform-provider-power-platform)
* [AzureRM](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
* [AzureAD](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs)
* [GitHub](https://registry.terraform.io/providers/integrations/github/latest/docs)
* [Random](https://registry.terraform.io/providers/hashicorp/random/latest/docs)
* [Null](https://registry.terraform.io/providers/hashicorp/null/latest/docs)

## Getting Started

The example terraform modules in this repo can be run by GitHub Actions or locally using the terraform CLI in the provided dev container.  Before you are able to run the examples there are several prerequisites that need to be completed.  The [bootstrap](bootstrap/README.md) scripts provided will create and configure the prerequisites that are needed to run the quickstart examples automatically.  You can also manually create and configure the prerequisites if you prefer.

## Running a Quickstart

The "Hello Power Platform" quickstart is a simple example that deploys a Power Platform environment. The quickstart is intended to demonstrate how to use the Power Platform terraform provider to deploy a Power Platform resources. You can edit the `examples/101-hello-power-platform/main.tf` file to change the attributes of the Power Platform environment that is deployed.

``` bash
cd examples/101-hello-power-platform

# initialize terraform (backend.tfvars is created by the bootstrap script)
terraform init -backend-config=../../backend.tfvars

# plan the deployment and show the changes that will be made
terraform plan -out=tfplan

# apply the changes
terraform apply tfplan

# destroy the resources
terraform destroy
```
