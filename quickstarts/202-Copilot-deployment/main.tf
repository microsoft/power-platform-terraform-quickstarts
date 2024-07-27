terraform {
  required_providers {
    powerplatform = {
      source = "microsoft/power-platform"
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

provider "azurecaf" {}

#---- 1 - Generate resource names using Azure CAF ----

resource "azurecaf_name" "resource_group" {
  resource_type = "azurerm_resource_group"
  prefixes = ["copilot-quickstart"]
  random_length = 5
  clean_input = true
}

# Using 'general' type for these newer/misc resources until support is added
resource "azurecaf_name" "openai_account" {
  name       = "openai-account"
  resource_type = "general"
  prefixes = ["copilot-quickstart"]
  random_length = 5
  clean_input = true
}

resource "azurecaf_name" "openai_deployment" {
  name       = "openai-deployment"
  resource_type = "general"
  prefixes = ["copilot-quickstart"]
  random_length = 5
  clean_input = true
}

resource "azurecaf_name" "power_platform_environment" {
  name       = "power-platform-environment"
  resource_type = "general"
  prefixes = ["copilot-quickstart"]
  random_length = 5
  clean_input = true
}

resource "azurecaf_name" "copilot" {
  resource_type = "general"
  prefixes = ["copilot-quickstart"]
  random_length = 5
  clean_input = true
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
  display_name      = azurecaf_name.power_platform_environment.result
  environment_type  = var.environment_type
  dataverse = {
    language_code     = var.language_code
    currency_code     = var.currency_code
    security_group_id = var.environment_access_group_id
  }
}

#---- 4 - Set up Azure resources ----

# Define resource group
resource "azurerm_resource_group" "Copilot-Deployment-Quickstart-RG" {
  name     = azurecaf_name.resource_group.result
  location = var.azure_location
}

locals {
  deployment_map = {
    dev = {
      "chat_model_gpt_4o_2024_05_13" = {
        name          = "deployment-${azurecaf_name.copilot.result}"
        model_format  = "OpenAI"
        model_name    = "gpt-4o"
        model_version = "2024-05-13"
        scale_type    = "Standard"
        capacity      = 1
      },
    }
  }
}

module "openai" {
  source = "Azure/openai/azurerm"
  version = ">=0.1.3"
  account_name = azurecaf_name.copilot.result
  custom_subdomain_name = azurecaf_name.resource_group.result
  resource_group_name = azurerm_resource_group.Copilot-Deployment-Quickstart-RG.name
  location = var.azure_location
  public_network_access_enabled = true
  deployment = local.deployment_map[var.environment]
  depends_on = [azurerm_resource_group.Copilot-Deployment-Quickstart-RG]
}

#---- 5 - Set up Power Platform connector ----

#TODO waiting on Mateusz

#---- 6 - Set up Dataverse record for the Copilot ----

resource "powerplatform_data_record" "copilot" {
  environment_id     = powerplatform_environment.dev.id
  table_logical_name = "bot"
  columns = {
    name        = azurecaf_name.copilot.result
    configuration = "{\n  \"$kind\" : \"BotConfiguration\",\n  \"publishOnCreate\" : true,\n  \"settings\" : {\n  \"GenerativeActionsEnabled\" : false,\n  },\n  \"isLightweightBot\" : true\n}"
  }
}

#---- 7 - Future state: base bot configuration eventually needs model knowledge source ----