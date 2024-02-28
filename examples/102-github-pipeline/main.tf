terraform {
  required_providers {
    powerplatform = {
      source  = "microsoft/power-platform"
      version = "0.8.4-preview"
    }
  }

  backend "azurerm" {
    container_name = "tfstate"
    key            = "pipeline-example-test3.terraform.tfstate"
    use_oidc = true
  }
}

provider "powerplatform" {
  use_oidc = true
}

  resource "powerplatform_environment" "dev" {
    location          = "unitedstates"
    language_code     = 1033
    display_name      = "pipeline-example-test3"
    currency_code     = "USD"
    environment_type  = "Sandbox"
    security_group_id = "00000000-0000-0000-0000-000000000000"
  }

