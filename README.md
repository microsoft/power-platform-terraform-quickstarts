# Power Platform Terraform Quickstarts

This repository contains example terraform modules that can be used to quickly deploy Power Platform environments and other Azure resources.  The modules are intended to demonstrate some common scenarios where managing Power Platform resources along side Azure, [Entra](https://entra.microsoft.com), or other resources can be facilitated with the [Terraform Provider for Power Platform](https://github.com/microsoft/terraform-provider-power-platform).  The modules are examples and are not intended to be used in production environments without modification.

This repository contains scripts quickly build out a new tenant and configure it to allow you to deploy and manage Power Platform environments along side other Azure resources. The scripts assume that you are starting with a completely new tenant with an empty Azure subscription.  This is a template repository that is intended to let you fork and customize the Power Platform/Azure resources to accommodate your own needs.

## Prerequisites

* Microsoft Tenant that you have `global admin` or `user administrator` permissions in
* Azure subscription in the tenant that you have `owner` permissions in
* A fork of this GitHub repository that you have `admin` permissions in

### Tooling

**_NOTE:_** The following tooling is pre-installed in the [VS Code Dev Container](https://code.visualstudio.com/docs/devcontainers/containers) and it is highly recommended that you use the Dev Container to run the scripts and terraform modules in this repository:

* [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/)
* [Terraform CLI](https://developer.hashicorp.com/terraform/cli)
* [GitHub CLI](https://cli.github.com/)
* [Docker](https://www.docker.com/)

### Terraform Providers

The following terraform providers are used in this repository:

* [PowerPlatform](https://github.com/microsoft/terraform-provider-power-platform)
* [AzureRM](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
* [AzureAD](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs)
* [GitHub](https://registry.terraform.io/providers/integrations/github/latest/docs)
* [Random](https://registry.terraform.io/providers/hashicorp/random/latest/docs)
* [Null](https://registry.terraform.io/providers/hashicorp/null/latest/docs)

## Getting Started

The example terraform modules are intended to be run by GitHub Actions, however there are several steps that need to be run locally by an administrator in order to create the resources the terraform modules need to use.  The following steps should be run in order:

1. [Bootstrap](bootstrap/README.md) this will create and configure the prerequisites that are needed to run the quickstart examples.
2. Check out **Quickstart Examples**

**_NOTE:_**  **As long as provider is in private repository, you have to run [/bootstrap/mirror/mirror.sh](/bootstrap/mirror/mirror.sh) first to copy provider locally**

## Quickstart Examples

**TODO** Generate list of examples and link to them. move quickstartgen.go from the other repo
 - basisc sensible
 - basic with storage 
 - pipeline
 - checkov
 - rest of them from other repo
**end TODO**