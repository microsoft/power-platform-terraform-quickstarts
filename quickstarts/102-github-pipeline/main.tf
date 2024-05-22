terraform {
  required_providers {
    power-platform = {
      source  = "microsoft/power-platform"
      version = "2.0.2-preview"
    }
  }

  backend "azurerm" {
    container_name = "tfstate"
    key            = "pipeline-example.terraform.tfstate"
    use_oidc = true
  }
}

provider "power-platform" {
  use_oidc = true
}

 resource "power-platform_environment" "dev" {
   location          = "unitedstates"
   display_name      = "pipeline-example"
   environment_type  = "Sandbox"
   dataverse = {
    language_code     = 1033
    currency_code     = "USD"
    security_group_id = "00000000-0000-0000-0000-000000000000"
   }
 }

