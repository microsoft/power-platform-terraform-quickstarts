terraform {
  required_providers {
    powerplatform = {
      source  = "microsoft/power-platform"
      version = "0.5.0-preview"
    }
  }

  backend "azurerm" {
    resource_group_name  = "value"
    storage_account_name = "value"
    container_name       = "tfstate"
    key                  = "pipeline-example.terraform.tfstate"
  }
}

resource "powerplatform_environment" "dev" {
  location          = "unitedstates"
  language_code     = 1033
  display_name      = "pipeline-example"
  currency_code     = "USD"
  environment_type  = "Sandbox"
  domain            = "pipeline-example"
  security_group_id = "00000000-0000-0000-0000-000000000000"
}
