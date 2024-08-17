terraform {
  required_providers {
    azurecaf = {
      source = "aztfmod/azurecaf"
      version = ">=1.2.28"
    }
  }
}

#---- 1 - Generate resource names using Azure CAF ----

resource "azurecaf_name" "resource_group" {
  resource_type = "azurerm_resource_group"
  prefixes = var.base-naming-prefix
  random_length = var.random-length
  clean_input = true
}

# Using 'general' type for these newer/misc resources until support is added
resource "azurecaf_name" "openai_account" {
  name       = "openai-account"
  resource_type = "general"
  prefixes = var.base-naming-prefix
  random_length = var.random-length
  clean_input = true
}

resource "azurecaf_name" "openai_deployment" {
  name       = "openai-deployment"
  resource_type = "general"
  prefixes = var.base-naming-prefix
  random_length = var.random-length
  clean_input = true
}

resource "azurecaf_name" "power_platform_environment" {
  name       = "environment"
  resource_type = "general"
  prefixes = var.base-naming-prefix
  random_length = var.random-length
  clean_input = true
}

resource "azurecaf_name" "copilot_name" {
  resource_type = "general"
  prefixes = var.base-naming-prefix
  random_length = var.random-length
  clean_input = true
}

resource "azurecaf_name" "quickstart_data_storage" {
  resource_type = "azurerm_storage_account"
  prefixes = var.base-naming-prefix
  random_length = var.random-length
  clean_input = true
  separator = ""
}

resource "azurecaf_name" "data_container" {
  resource_type = "azurerm_storage_container"
  prefixes = var.base-naming-prefix
  random_length = var.random-length
  clean_input = true
  separator = ""
}

resource "azurecaf_name" "ai_search" {
  resource_type = "general"
  prefixes = var.base-naming-prefix
  random_length = var.random-length
  clean_input = true
}

resource "azurecaf_name" "ai_search_datasource" {
  resource_type = "general"
  prefixes = var.base-naming-prefix
  random_length = var.random-length
  clean_input = true
}