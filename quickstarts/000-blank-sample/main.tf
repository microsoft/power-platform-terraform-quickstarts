terraform {
  required_version = ">= 1.5"
  required_providers {
    powerplatform = {
      source = "microsoft/power-platform"
    }
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

provider "powerplatform" {
  use_cli = true
}


resource "powerplatform_environment" "development" {
  display_name      = "example_environment"
  location          = "europe"
  language_code     = "1033"
  currency_code     = "USD"
  environment_type  = "Sandbox"
}

data "powerplatform_connectors" "all_connectors" {}

# data "azurerm_resource_group" "example" {
#   name     = "example"
#   location = "West Europe"
# }
