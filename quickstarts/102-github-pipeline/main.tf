terraform {
  required_providers {
    powerplatform = {
      source  = "microsoft/power-platform"
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

resource "powerplatform_environment" "dev" {
   location          = "unitedstates"
   display_name      = "pipeline-example"
   environment_type  = "Sandbox"
   dataverse = {
    language_code     = 1033
    currency_code     = "USD"
    security_group_id = "00000000-0000-0000-0000-000000000000"
   }
 }

