<!-- This document is auto-generated. Do not edit directly. Make changes to README.md.tmpl instead. -->
# Demo Tenant Example (103 level)

Provides a basic sample how to setup a demo tenant with users that each have a developer environment.

Licenses required for Power Platform development are managed via a Maker security group to allow Power Apps and Power Automate development

## Prerequisites

- Entra ID Tenant
- Already executed [bootsrap](../../bootstrap/README.md) script

## Example Files

The example files can be found in `quickstarts/103-demo-tenant`

## Provider Requirements

The Terraform plugins or "providers" that this IaC deployment requires are:

- **azuread:** (any version)

- **azurerm:** (any version)

- **external:** (any version)

- **local:** (any version)

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `group_description` | The description of the Azure AD group | string | `null` | true |
| `group_name` | The display name of the Azure AD group | string | `null` | true |

## Data Sources

- `data.external.available_license_skus` from `external`

- `data.external.domain_name` from `external`

- `data.external.tenant_id` from `external`

- `data.local_file.users` from `local`

## Child Modules

- `environments` from `./modules/environments`

- `groups` from `./modules/groups`

- `licenses` from `./modules/licenses`

- `users` from `./modules/users`

## Usage

Login to your Azure tenant

```
az login --use-device-code --allow-no-subscriptions
```

Login to the Power Platform CLI replacing **01234567-1111-2222-3333-44445555666** with your tenant

```
pac auth clear
pac auth create --tenant 01234567-1111-2222-3333-44445555666
```

Apply the script using sample values

```
terraform apply -var-file=sample.tfvars.txt
```

## Detailed Behavior

### Environments Module

The environemnts modules creates following resources:

- Power Platform Developer environments in the format "{firstName} {latName} Dev"

### Groups Module

The environemnts modules creates following resources:

- Entra security enabled group using provided variable
- Members of group from variable

### Licenses

The licenses modules creates following resources:

- Assignment of licenses to an Entra Security group

### Users

The users modules creates following resources:

- Entra users with a random password

## Limitations and Considerations

- This module is provided as a sample only and is not intended for production use without further customization.