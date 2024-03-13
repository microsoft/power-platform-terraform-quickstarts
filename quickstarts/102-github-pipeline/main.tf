terraform {
  required_providers {
    powerplatform = {
      source  = "microsoft/power-platform"
      version = "0.10.0-preview"
    }
    azuread = {
      source = "hashicorp/azuread"
    }
    random = {
      source = "hashicorp/random"
    }
  }

  backend "azurerm" {
    container_name = "tfstate"
    key            = "pipeline-example.terraform.tfstate"
    use_oidc = true
  }
}

provider "powerplatform" {
  use_oidc = true
}

provider "azuread" {
  use_oidc = true
}

data "azuread_domains" "aad_domains" {
  only_initial = true
}


locals {
  domain_name = data.azuread_domains.aad_domains.domains[0].domain_name
}

resource "random_password" "passwords" {
  length           = 16
  special          = true
  override_special = "_%@"
}

locals {
  dev_users = toset([ "dev1", "dev2" ])
}



resource "azuread_user" "dev_user" {
 // count = length(local.dev_users)
  for_each = local.dev_users
  //user_principal_name = "${local.dev_users[count.index]}@${local.domain_name}"
  user_principal_name = "${each.value}@${local.domain_name}"
  //display_name        = local.dev_users[count.index]
  //mail_nickname       = local.dev_users[count.index]
  display_name        = each.value
  mail_nickname       = each.value
  password = random_password.passwords.result
  usage_location = "US"
}

resource "azuread_group" "dev_access" {
  display_name = "Dataverse Dev Environment Access"
  description  = "Dataverse Dev Environment Access Group for Power Platform"
  mail_enabled = false
  security_enabled = true 
  members = values(azuread_user.dev_user)[*].id
}

resource "powerplatform_environment" "dev" {
  location          = "unitedstates"
  language_code     = 1033
  display_name      = "dev-main"
  currency_code     = "USD"
  environment_type  = "Sandbox"
  security_group_id = azuread_group.dev_access.id
}

data "powerplatform_securityroles" "all" {
  environment_id = powerplatform_environment.dev.id
}

resource "powerplatform_user" "new_user" {
  for_each = azuread_user.dev_user
  environment_id = powerplatform_environment.dev.id
  security_roles = toset([for role in data.powerplatform_securityroles.all.security_roles : role.role_id if 
    role.name == "System Customizer" || 
    role.name ==  "Environment Maker"
  ])
  aad_id = azuread_user.dev_user[each.key].id

  depends_on = [ azuread_group.dev_access ]
}


resource "powerplatform_environment" "user_dev_env" {
  for_each = azuread_user.dev_user
  location          = "unitedstates"
  language_code     = 1033
  display_name      = "${azuread_user.dev_user[each.key].mail_nickname}-private-development"
  currency_code     = "USD"
  environment_type  = "Sandbox"
  security_group_id = azuread_group.dev_access.id
}

data "powerplatform_securityroles" "user_dev_env_roles" {
  //count = length(powerplatform_environment.user_dev_env)
  for_each = powerplatform_environment.user_dev_env
  environment_id = powerplatform_environment.user_dev_env[each.key].id
}

resource "powerplatform_user" "user_dev_env" {
  for_each = azuread_user.dev_user
  environment_id = powerplatform_environment.user_dev_env[each.key].id
  security_roles = toset([for role in data.powerplatform_securityroles.user_dev_env_roles[each.key].security_roles : role.role_id if 
    role.name == "System Administrator"
  ])
  aad_id = azuread_user.dev_user[each.key].id

  depends_on = [ azuread_group.dev_access ]
}


resource "azuread_group" "test_access" {
  display_name = "Dataverse Test Environment Access"
  description  = "Dataverse Test Environment Access Group for Power Platform"
  mail_enabled = false
  security_enabled = true 
}

resource "powerplatform_environment" "test" {
  location          = "unitedstates"
  language_code     = 1033
  display_name      = "test"
  currency_code     = "USD"
  environment_type  = "Sandbox"
  security_group_id = azuread_group.test_access.id
}

resource "azuread_group" "prod_access" {
  display_name = "Dataverse Prod Environment Access"
  description  = "Dataverse Prod Environment Access Group for Power Platform"
  mail_enabled = false
  security_enabled = true 
}

resource "powerplatform_environment" "prod" {
  location          = "unitedstates"
  language_code     = 1033
  display_name      = "prod"
  currency_code     = "USD"
  environment_type  = "Production"
  security_group_id = azuread_group.prod_access.id
}