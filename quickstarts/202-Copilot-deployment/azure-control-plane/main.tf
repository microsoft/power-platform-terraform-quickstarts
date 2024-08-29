terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">=3.113.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  deployment_map = {
    dev = {
      "chat_model_gpt_4o_2024_05_13" = {
        name          = "deployment-${var.copilot_name}"
        model_format  = "OpenAI"
        model_name    = "gpt-4o"
        model_version = "2024-05-13"
        scale_type    = "Standard"
        capacity      = 1
      },
    }
  }
}

#---- 2 - Set up Azure resources ----

# Define resource group for the quickstart resources
resource "azurerm_resource_group" "Copilot-Deployment-Quickstart-RG" {
  name     = var.resource_group
  location = var.azure_location
}

# Create OpenAI resources
module "openai" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"
  source = "Azure/openai/azurerm"
  version = ">=0.1.3"
  account_name = var.copilot_name
  custom_subdomain_name = var.resource_group
  resource_group_name = azurerm_resource_group.Copilot-Deployment-Quickstart-RG.name
  location = var.azure_location
  public_network_access_enabled = true
  deployment = local.deployment_map[var.openai_environment]
  depends_on = [azurerm_resource_group.Copilot-Deployment-Quickstart-RG]
}

#---- 3 - Create storage and search resources ----
# To be connected to the model in the Power Platform module

# Storage account
resource "azurerm_storage_account" "Quickstart-Data-Storage" {
  name                     = var.data_storage
  resource_group_name      = azurerm_resource_group.Copilot-Deployment-Quickstart-RG.name
  location                 = var.azure_location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  min_tls_version          = "TLS1_2"
  public_network_access_enabled = false
}

# Container in the storage account
resource "azurerm_storage_container" "Quickstart-Data-Container" {
  name                  = var.data_container
  storage_account_name  = azurerm_storage_account.Quickstart-Data-Storage.name
  container_access_type = "private"
}

# Search service
resource "azurerm_search_service" "Quickstart-Data-Search" {
  name                = var.ai_search
  resource_group_name = azurerm_resource_group.Copilot-Deployment-Quickstart-RG.name
  location            = var.azure_location
  sku                 = "basic"
  replica_count = 3
  public_network_access_enabled = false
}