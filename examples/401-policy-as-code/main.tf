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
      version = "0.4.0-preview"
    }
  }

  backend "azurerm" {
    container_name = "tfstate"
    key            = "401-policy-as-code.terraform.tfstate"
  }
}

resource powerplatform_environment foo {
  location          = "unitedstates"
  language_code     = 1033
  display_name      = "foo"
  currency_code     = "USD"
  environment_type  = "Trial"
  security_group_id = "00000000-0000-0000-0000-000000000001"
  domain            = "myspecialdomain"
}

