<!-- This document is auto-generated. Do not edit directly. Make changes to README.md.tmpl instead. -->
# Github Pipeline Example (102 level)

This example demostrates how to create a pipeline that will deploy Power Platform environment using Terraform.

## Prerequisites

- Entra ID Tenant
- Azure subscription where the terraform state will be stored
- Power Platform environment
- Already executed [bootsrap](../../bootstrap/README.md) script
- Configured federation between GitHub repository that you use this pipeline and Entra ID tenant: <https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-azure>

{{ .ModuleDetails }}

## Usage

You can fork or download this repository and use it as a starting point for your own pipeline. Copy the [tf-102-example-pipeline.yml](./tf-102-example-pipeline.yml) to the `.github/workflows` directory in your repository.

You will have to set folowwing [variables in your repository](https://docs.github.com/en/actions/learn-github-actions/variables):

- PPADMIN_CLIENT_ID = <your tenant id>
- PPADMIN_TENANT_ID = <bootstraped service principal tenantId>
- PPADMIN_SUBSCRIPTION_ID = <your subscription id>
- TF_STATE_STORAGE_ACCOUNT_NAME = <your storage account name, created by bootstrap.sh>
- TF_STATE_RESOURCE_GROUP_NAME  = <your resource group name, created by bootstrap.sh>

To run the pipeline you will have to create a new branch based on your main branch and push and create a pull request. The pipeline will run `Terraform Plan` step on every push to the repository.
The pipeline will authenticate using OpenID Connect and will require setting federation between GitHub repository and Entra ID tenant. With federation configured no additional credentials are required to executed pipeline steps against Azure or Power Platform.

![Pipeline](./.img/pr_approval.png)

The Terraform Plan output will also be added to your pull request as a comment:

![Pipeline](./.img/plan_output.png)

## Detailed Behavior

The pipeline example was created to demonstrate how to deploy Power Platform environment using Terraform. The pipeline is created from two steps

- `Terraform Plan`: is responsible for creating a plan of the changes that will be applied to the infrastructure. The plan is stored as an artifact and can be reviewed before applying the changes. This step will run on every push to the repository.

- `Terraform Apply`: is responsible for applying the changes to the infrastructure. The changes are applied only if the plan was reviewed and approved. This step will run on every push `main` branch.

![Pipeline](./.img/terraform_apply.png)

## Limitations and Considerations

- This module is provided as a sample only and is not intended for production use without further customization.
