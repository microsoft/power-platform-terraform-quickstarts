terraform {
  required_providers {
    azuread = {
      source = "hashicorp/azuread"
    }
    azurerm = {
      source = "hashicorp/azurerm"
    }
    random = {
      source = "hashicorp/random"
    }
    null = {
      source = "hashicorp/null"
    }
    powerplatform = {
      source  = "microsoft/power-platform"
      version = "0.3.0-preview"
    }
  }

  backend "azurerm" {
    container_name = "tfstate"
    key            = "terraform.tfstate"
  }
}


# module "identity" {
#   source  = "./identity"
#   aliases = var.aliases
# }


module "powerplatform" {
  source    = "./powerplatform"
}