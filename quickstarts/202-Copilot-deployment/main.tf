terraform {
  required_providers {
    powerplatform = {
      source = "microsoft/power-platform"
      #TODO update to 2.7.0-preview once it's out to support connections
      version = "2.6.2-preview"
    }
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">=3.113.0"
    }
    azurecaf = {
      source = "aztfmod/azurecaf"
      version = ">=1.2.28"
    }
  }
}

provider "powerplatform" {
  use_cli = true
}

provider "azurerm" {
  features {}
}

module "azure" {
  source  = "./azure"
}

module "power-platform" {
  source = "./power-platform"
  environment_display_name = module.azure.power-platform_environment_name
  copilot_name = module.azure.copilot_name
}