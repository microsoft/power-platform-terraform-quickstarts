<!-- This document is auto-generated. Do not edit directly. Make changes to README.md.tmpl instead. -->
# Deploy a Copilot to Copilot Studio (202)

This Terraform module is an end-to-end example for connecting a low-code Copilot in Copilot Studio to a high-code Azure OpenAI resource. It demonstrates how to deploy OpenAI model resources to Azure, then deploy a connection to that model to Power Platform, and finally deploy a Copilot to Copilot Studio.

## Prerequisites

- Entra ID Tenant
- Power Platform environment
- Sufficient [Azure OpenAI Service quota](https://learn.microsoft.com/en-us/azure/ai-services/openai/quotas-limits) for the model(s) you intend to deploy

## Example Files

The example files can be found in `quickstarts/202-Copilot-deployment`

## Provider Requirements

The Terraform plugins or "providers" that this IaC deployment requires are:

- **azurecaf (`aztfmod/azurecaf`):** `>=1.2.28`

- **azurerm (`hashicorp/azurerm`):** `>=3.113.0`

- **powerplatform (`microsoft/power-platform`):** `2.6.2-preview`

## Child Modules

- `azure` from `./azure`

- `power-platform` from `./power-platform`

## Usage

Execute example with the following commands:

```bash
az login --allow-no-subscriptions --scope https://api.bap.microsoft.com/.default

terraform init

terraform apply
```

## Detailed Behavior

### Azure Module

The Azure module does the following work:

- Creates consistent resource names using Azurecaf
- Creates a resource group for OpenAI resources
- Creates an OpenAI model resource and deployment using a local deployment map definition and AzureRM's openai module

### Power Platform Module

The Power Platform module does the following work:

- Configures tenant-level settings for smooth copilot deployment and model connection
- Creates a new Power Platform environment
- Deploys a connection to the OpenAI model that was created in the Azure module
- Deploys a blank Copilot

## Limitations and Considerations

- The OpenAI connection is immediately available in Copilot Studio after this module is executed, and can be accessed in generative answers by following [these instructions](https://learn.microsoft.com/en-us/microsoft-copilot-studio/nlu-generative-answers-azure-openai).
