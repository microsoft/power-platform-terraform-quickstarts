# Demo Tenant Example (103 level)

Provides a basic sample how to setup a demo tenant with users that each have a developer environment.

Licenses required for Power Platform development are managed via a Maker security group to allow Power Apps and Power Automate development.

## Prerequisites

- Entra ID Tenant
- Already executed [bootsrap](../../bootstrap/README.md) script

## Getting Started

1. Login to your Azure tenant

```
az login --use-device-code --allow-no-subscriptions
```

1. Login to the Power Platform CLI replacing **01234567-1111-2222-3333-44445555666** with your tenant

```
pac auth clear
pac auth create --tenant 01234567-1111-2222-3333-44445555666
```

2. Apply the script using sample values

```
terraform apply -var-file=sample.tfvars.txt
```

## Limitations and Considerations

- This module is provided as a sample only and is not intended for production use without further customization.