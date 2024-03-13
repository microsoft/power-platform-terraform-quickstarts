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

resource "azuread_user" "dev_user1" {
  user_principal_name = "dev1@${local.domain_name}"
  display_name        = "Dev User1"
  mail_nickname       = "dev1"
  password = random_password.passwords.result
}

resource "azuread_group" "dev_access" {
  display_name = "Dataverse Dev Access"
  description  = "Dataverse Dev Access Group for Power Platform"
  mail_enabled = false
  security_enabled = true
}

resource "azuread_group_member" "user1_member" {
  group_object_id = azuread_group.dev_access.id
  member_object_id = azuread_user.dev_user1.id
}

resource "powerplatform_environment" "dev" {
  location          = "unitedstates"
  language_code     = 1033
  display_name      = "pipeline-example"
  currency_code     = "USD"
  environment_type  = "Sandbox"
  security_group_id = azuread_group.dev_access.id
}

data "powerplatform_securityroles" "all" {
  environment_id = powerplatform_environment.dev.id
}

locals {
  developer_roles = toset([for role in data.powerplatform_securityroles.all.security_roles : role.role_id if 
    role.name == "System Customizer" || 
    role.name ==  "Environment Maker"
  ])
}

resource "powerplatform_user" "new_user" {
  environment_id = powerplatform_environment.dev.id
  security_roles = local.developer_roles
  aad_id = azuread_user.dev_user1.id
}