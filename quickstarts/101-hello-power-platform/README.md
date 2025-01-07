<!-- This document is auto-generated. Do not edit directly. Make changes to README.md.tmpl instead. -->
# Hello Power Platform (101 level)

This Terraform module aims to provide a fully managed infrastructure that integrates Microsoft's Power Platform and Azure services. Utilizing both power-platform and azurerm Terraform providers, this module encapsulates best practices and serves as a reference architecture for scalable, reliable, and manageable cloud infrastructure.

## Prerequisites

- Entra ID Tenant
- Power Platform environment
- Already executed [bootsrap](../../bootstrap/README.md) script

## Example Files

The example files can be found in `quickstarts/101-hello-power-platform`

## Provider Requirements

The Terraform plugins or "providers" that this IaC deployment requires are:

- **azuread (`hashicorp/azuread`):** (any version)

- **null (`hashicorp/null`):** (any version)

- **powerplatform (`microsoft/power-platform`):** `>=3.3.0`

- **random (`hashicorp/random`):** (any version)

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `aliases` | The aliases to create users for | list(string) | `["test1","test2"]` | false |

## Output Values

| Name | Description |
|------|-------------|
| `dev_environment` |  |
| `dev_environment_access_group` |  |
| `test_environment` |  |
| `test_environment_access_group` |  |
| `user_credentials` |  |

## Child Modules

- `identity` from `./identity`

- `power-platform` from `./power-platform`

## Usage

Execute example with the following commands:

```bash
az login --allow-no-subscriptions --scope api://power-platform_provider_terraform/.default

terraform init

terraform apply
```

## Detailed Behavior

### Idenity Module

The identity modules creates following resources:

- given amout of users with aliases specified by `aliases` variable.
- Entra security group that will be used to secure access to DEV Power Platform environment.
- Entra security group that will be used to secure access to TEST Power Platform environment.

### Power Platform Module

The Powe Platform modules creates following resources:

- DEV Power Platform environment
- TEST Power Platform environment
- enables mananged environment for DEV and TEST environments
- secures DEV and TEST environments with Entra security groups created in the identity module

## Limitations and Considerations

- This module is provided as a sample only and is not intended for production use without further customization.
