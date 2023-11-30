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
      version = "0.5.0-preview"
    }
  }

  # backend "azurerm" {
  #   container_name = "tfstate"
  #   key            = "101-hello-power-platform.terraform.tfstate"
  # }
}


# module "identity" {
#   source  = "./identity"
#   aliases = var.aliases
# }


module "powerplatform" {
  source = "./powerplatform"
  billing_policy_resource_group = var.billing_policy_resource_group
  billing_policy_subscription_id = var.billing_policy_subscription_id
}