terraform {
  required_providers {
    powerplatform = {
      source = "microsoft/power-platform"
      version = ">=2.6.1-preview"
    }
    azurerm = {
      source = "hashicorp/azurerm"
    }
    caf = {
      source = "aztfmod/caf"
    }
  }
}

provider "powerplatform" {
  use_cli = true
}

provider "azurerm" {
  features {}
}

provider "caf" {}

#---- 1 - Generate resource names using Azure CAF ----

resource "caf_naming_convention" "resource_group" {
  convention = "ResourceGroup"
  name       = "copilot-quickstart-rg"
  environment = var.environment
  project    = var.project
}

resource "caf_naming_convention" "openai_account" {
  convention = "OpenAIAccount"
  name       = "copilot-quickstart-openai-account"
  environment = var.environment
  project    = var.project
}

resource "caf_naming_convention" "openai_deployment" {
  convention = "OpenAIDeployment"
  name       = "copilot-quickstart-openai-deployment"
  environment = var.environment
  project    = var.project
}

resource "caf_naming_convention" "power_platform_environment" {
  convention = "PowerPlatformEnvironment"
  name       = "copilot-quickstart-power-platform-environment"
  environment = var.environment
  project    = var.project
}

#---- 2 - Set key tenant settings

resource "powerplatform_tenant_settings" "settings" {

  power_platform = {
    power_automate = {
      disable_copilot           = false
      # Optional
      disable_copilot_with_bing = false
    }
    intelligence = {
      disable_copilot                   = false
      enable_open_ai_bot_publishing     = true
    }
  }
}

#---- 3 - Generate a new Power Platform environment ----

resource "powerplatform_environment" "dev" {
  location          = var.powerplatform_location
  display_name      = caf_naming_convention.power_platform_environment.result
  environment_type  = var.environment_type
  dataverse = {
    language_code     = var.language_code
    currency_code     = var.currency_code
    security_group_id = var.environment_access_group_id
  }
}

#---- 4 - Set up Azure resources ----

# Define resource group
resource "azurerm_resource_group" "Copilot Deployment Quickstart RG" {
  name     = caf_naming_convention.resource_group.result
  location = var.azure_location
}

# Define Azure OpenAI resource
resource "azurerm_openai_account" "Copilot Deployment Quickstart OAI Service" {
  name                = caf_naming_convention.openai_account.result
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku_name            = "S0"
}

# Define an Azure OpenAI deployment
resource "azurerm_openai_deployment" "Copilot Deployment Quickstart OAI Deployment" {
  name                = caf_naming_convention.openai_deployment.result
  openai_account_name = azurerm_openai_account.example.name
  resource_group_name = azurerm_resource_group.example.name
  model_name          = "gpt-4"
  scale_type          = "Standard"
}

#---- 5 - Set up Power Platform connector ----

#TODO waiting on Mateusz

#---- 6 - Set up Dataverse record for the bot ----

#---- 7 - Future state: base bot configuration eventually needs model knowledge source ----