# Configure the Azure Resource Manager provider
provider "azurerm" {
  features {}
}

# Configure the Azure Active Directory provider
provider "azuread" {
  tenant_id = data.external.tenant_id.result.result
}

# Configure the local provider
provider "local" {}

# Retrieve the domain name of the current user
data "external" "domain_name" {
  program = ["pwsh", "-Command", <<EOT
    $user = az account show --query user.name --output tsv
    $domain = $user.Split('@')[1]
    $result = @{ result = $domain }
    $result | ConvertTo-Json -Compress
  EOT
  ]
}

# Retrieve the tenant ID of the current Azure account
data "external" "tenant_id" {
  program = ["pwsh", "-Command", <<EOT
    $tenantId = az account show --query tenantId --output tsv
    $result = @{ result = $tenantId }
    $result | ConvertTo-Json -Compress
  EOT
  ]
}

# Retrieve available license SKUs using an external script
data "external" "available_license_skus" {
  program = ["pwsh", "./get_license_skus.ps1"]
}

# Split the retrieved license SKUs into a list
locals {
  license_skus = split(",", data.external.available_license_skus.result.result)
}

# Read the users from a local JSON file
data "local_file" "users" {
  filename = "${path.module}/users.json"
}

# Decode the JSON content into a local variable
locals {
  users = jsondecode(data.local_file.users.content)
}

# Module to manage users
module "users" {
  source = "./modules/users"
  tenant_id = data.external.tenant_id.result.result
  users  = local.users
  domain = data.external.domain_name.result.result
}

# Module to manage groups
module "groups" {
  source = "./modules/groups"
  user_ids = module.users.user_ids
  group_name        = var.group_name
  group_description = var.group_description
  depends_on = [module.users]
}

# Module to assign licenses to groups
module "licenses" {
  source = "./modules/licenses"
  group_id = module.groups.group_id
  license_skus = local.license_skus
  depends_on = [module.groups]
}

locals {
  full_module_path = abspath(path.module)
}

module "environments" {
  source = "./modules/environments"

  users = local.users
  domain = data.external.domain_name.result.result
  full_module_path = local.full_module_path
  depends_on = [module.licenses]
}