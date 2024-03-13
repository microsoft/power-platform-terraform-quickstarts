terraform {
  required_providers {
    powerplatform = {
      source  = "microsoft/power-platform"
      version = "0.10.0-preview"
    }
    azuread = {
      source = "hashicorp/azuread"
    }
    random = {
      source = "hashicorp/random"
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

provider "azuread" {
  use_oidc = true
}
