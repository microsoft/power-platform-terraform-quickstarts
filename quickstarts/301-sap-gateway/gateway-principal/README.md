# Service Principal Module for SAP Gateway  (200 level)

This Module contains the Terraform code required to create a Service Principal and application in Azure Active Directory. This Service Principal will be used to authenticate the SAP Gateway.

More information on the configurations required for this service principal can be found in the [the provider's user documentation](https://microsoft.github.io/terraform-provider-power-platform#authentication).

> [!NOTE]
> To use Terraform commands against your Azure subscription, you must first authenticate Terraform to that subscription. The article [Authenticate Terraform to Azure](https://learn.microsoft.com/en-us/azure/developer/terraform/authenticate-to-azure?tabs=bash)
> provides guidance on how to do this, remember to choose the correct subscription.
> It is highly recommended that you use the [VS Code Dev Container](https://code.visualstudio.com/docs/devcontainers/containers) to run the scripts and terraform modules in this repository.

You have to execute the normal Terraform commands:

``terraform init -upgrade

``terraform plan -var-file=local.tfvars

``terraform apply -var-file=local.tfvars

``terraform destroy -var-file=local.tfvars

## Terraform Version Constraints

- azurerm `>=3.74.0`
- azurecaf `>=1.2.26`

## Prerequisites

- Entra ID Tenant
- Azure subscription where the terraform state will be stored
- Power Platform environment (optional)

{{ .ModuleDetails }}

## Limitations and Considerations

- Due to Power Platform limitations, certain resources may not fully support Terraform's state management.
- Make sure to set appropriate RBAC for Azure and Power Platform resources.
- This module is provided as a sample only and is not intended for production use without further customization.

## Additional Resources

- [Power Platform Admin Documentation](https://learn.microsoft.com/en-us/power-platform/admin/)
- [Azure AD Terraform Provider](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/guides/service_principal_configuration)
- <https://learn.microsoft.com/en-us/power-platform/admin/wp-onpremises-gateway>
