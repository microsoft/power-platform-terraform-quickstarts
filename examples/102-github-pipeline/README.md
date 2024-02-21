1. run bootstrap with azurerm backend
2. run mirror.sh if needed
3. every time set env variables for mirror.tfrc

setup env secrets for the pipeline unser "settings" -> "settings & variables" -> "actions"
https://docs.github.com/en/actions/learn-github-actions/variables

PPADMIN_CLIENT_SECRET = <bootstraped service principal secret>

#fine grainded token to releases in the terraform provider repo
https://github.com/settings/tokens?type=beta

PAT_TOKEN_PP_PROVIDER_REPO = <your personal access token>


setup env variables for the pipeline under "settings" -> "settings & variables" -> "actions"

PPADMIN_CLIENT_ID = <your tenant id>
PPADMIN_TENANT_ID = <bootstraped service principal tenantId>
PPADMIN_SUBSCRIPTION_ID = <your subscription id>

TF_STATE_STORAGE_ACCOUNT_NAME = <your storage account name, created by bootstrap.sh>
TF_STATE_RESOURCE_GROUP_NAME  = <your resource group name, created by bootstrap.sh>




terraform init -backend-config=../../backend.tfvars
terraform apply