terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">=3.113.0"
    }
    azurecaf = {
      source = "aztfmod/azurecaf"
      version = ">=1.2.28"
    }
    # azapi = {
    #   source = "Azure/azapi"
    #   version = ">=1.14.0"
    # }
  }
}

provider "azurerm" {
  features {}
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
  name       = "environment"
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

resource "azurecaf_name" "quickstart_data_storage" {
  resource_type = "azurerm_storage_account"
  prefixes = ["copilotquickstart"]
  random_length = 5
  clean_input = true
  separator = ""
}

resource "azurecaf_name" "quickstart_data_container" {
  resource_type = "azurerm_storage_container"
  prefixes = ["copilotquickstart"]
  random_length = 5
  clean_input = true
  separator = ""
}

resource "azurecaf_name" "quickstart_data_search" {
  resource_type = "general"
  prefixes = ["copilot-quickstart"]
  random_length = 5
  clean_input = true
}

#---- 2 - Set up Azure resources ----

# Define resource group for the quickstart resources
resource "azurerm_resource_group" "Copilot-Deployment-Quickstart-RG" {
  name     = azurecaf_name.resource_group.result
  location = var.azure_location
}

# Create OpenAI resources
module "openai" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
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

#---- 3 - Create storage and search resources ----
# To be connected to the model in the Power Platform module

# Storage account
resource "azurerm_storage_account" "Quickstart-Data-Storage" {
  name                     = azurecaf_name.quickstart_data_storage.result
  resource_group_name      = azurerm_resource_group.Copilot-Deployment-Quickstart-RG.name
  location                 = var.azure_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Container in the storage account
resource "azurerm_storage_container" "Quickstart-Data-Container" {
  name                  = azurecaf_name.quickstart_data_container.result
  storage_account_name  = azurerm_storage_account.Quickstart-Data-Storage.name
  container_access_type = "private"
}

# Search service
resource "azurerm_search_service" "Quickstart-Data-Search" {
  name                = azurecaf_name.quickstart_data_search.result
  resource_group_name = azurerm_resource_group.Copilot-Deployment-Quickstart-RG.name
  location            = var.azure_location
  sku                 = "basic"
}

# Connect the search service to storage
# resource "azapi_resource" "search_service_datasource" {
#   depends_on = [azurerm_storage_container.Quickstart-Data-Container, azurerm_search_service.Quickstart-Data-Search]
#   type      = "Microsoft.Search/searchServices/datasources@2023-11-01"
#   name      = azurerm_storage_container.Quickstart-Data-Container.name
#   parent_id = azurerm_search_service.Quickstart-Data-Search.id
#   body = jsonencode({
#     properties = {
#     dataSourceType = "AzureBlob"
#     connectionString = azurerm_storage_account.Quickstart-Data-Storage.primary_blob_connection_string
#     container = azurerm_storage_container.Quickstart-Data-Container.name
#     }
#   })
# }

# TODO add search index and indexer