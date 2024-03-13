terraform {
  required_providers {
    powerplatform = {
      source  = "microsoft/power-platform"
      version = "0.10.0-preview"
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

resource "azuread_user" "user1" {
  user_principal_name = "user1@mateuszwasilewskihotmail.onmicrosoft.com"
  display_name        = "User One"
  mail_nickname       = "user1"
}

resource "azuread_group" "dev_access" {
  display_name = "Dataverse Dev Access"
  description  = "Dataverse Dev Access Group for Power Platform"
  mail_enabled = false
  security_enabled = true
}

resource "azuread_group_member" "user1_member" {
  group_object_id = azuread_group.dev_access.id
  member_object_id = azuread_user.user1.id
}


resource "powerplatform_environment" "dev" {
  location          = "unitedstates"
  language_code     = 1033
  display_name      = "pipeline-example"
  currency_code     = "USD"
  environment_type  = "Sandbox"
  security_group_id = azuread_group.dev_access.id
}

