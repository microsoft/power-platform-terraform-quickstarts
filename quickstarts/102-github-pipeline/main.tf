terraform {
  required_providers {
    powerplatform = {
      source  = "microsoft/power-platform"
      version = ">=2.0.2-preview"
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

 resource "powerplatform_environment" "development" {
   location          = "europe"
   display_name      = "github-terraform-test"
   environment_type  = "Sandbox"
   dataverse = {
    language_code     = 1033
    currency_code     = "EUR"
    security_group_id = "00000000-0000-0000-0000-000000000000"
    domain            = "github-terraform-test"
   }
 }

