terraform {
  required_providers {
    azuread = {
      source = "hashicorp/azuread"
    }
    random = {
      source = "hashicorp/random"
    }
    null = {
      source = "hashicorp/null"
    }
    powerplatform = {
      source  = "microsoft/power-platform"
      version = "0.6.1-preview"
    }
  }
}

provider "powerplatform" {
  use_cli = true
}

module "identity" {
  source  = "./identity"
  aliases = var.aliases
}

module "powerplatform" {
  source = "./powerplatform"
  dev_environment_access_group_id  = module.identity.dev_environment_access_group.id
  test_environment_access_group_id = module.identity.test_environment_access_group.id
}