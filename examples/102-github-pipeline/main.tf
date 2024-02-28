terraform {
  required_providers {
    powerplatform = {
      source  = "microsoft/power-platform"
      version = "0.8.4-preview"
    }
  }

  backend "azurerm" {
    container_name = "tfstate"
    key            = "demo.terraform.tfstate"
    use_oidc = true
  }
}

provider "powerplatform" {
  use_oidc = true
}
  resource "powerplatform_environment" "dev" {
    location          = "unitedstates"
    language_code     = 1033
    display_name      = "demo-dev-update"
    currency_code     = "USD"
    environment_type  = "Sandbox"
    security_group_id = "00000000-0000-0000-0000-000000000000"
  }

  resource "powerplatform_environment" "test" {
    location          = "unitedstates"
    language_code     = 1033
    display_name      = "demo-test"
    currency_code     = "USD"
    environment_type  = "Sandbox"
    security_group_id = "00000000-0000-0000-0000-000000000000"
  }

