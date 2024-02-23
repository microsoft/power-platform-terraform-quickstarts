terraform {
  required_providers {
    powerplatform = {
      source  = "microsoft/power-platform"
      version = "0.7.12-preview"
    }
  }

  backend "azurerm" {
    container_name = "tfstate"
    key            = "pipeline-example.terraform.tfstate"
    use_oidc = true
  }
}

provider "powerplatform" {
  use_cli = true
}

 resource "powerplatform_environment" "dev" {
   location          = "unitedstates"
   language_code     = 1033
   display_name      = "pipeline-example1"
   currency_code     = "USD"
   environment_type  = "Sandbox"
   domain            = "pipeline-example"
   security_group_id = "00000000-0000-0000-0000-000000000000"
 }

