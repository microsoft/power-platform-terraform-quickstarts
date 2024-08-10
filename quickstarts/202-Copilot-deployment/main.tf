terraform {
  required_providers {
    powerplatform = {
      source = "microsoft/power-platform"
      version = "2.7.0-preview"
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

module "azure" {
  source  = "./azure"
}

module "power-platform" {
  source = "./power-platform"
  environment_display_name = module.azure.power-platform_environment_name
  copilot_name = module.azure.copilot_name
  oai_resource_name = module.azure.oai_resource_name
  oai_api_key = module.azure.oai_api_key
  search_endpoint_uri = module.azure.search_endpoint_uri
  search_api_key = module.azure.search_api_key
}

module "azure-configure" {
  source = "./azure-configure"
  storage_container_name = module.azure.storage_container_name
  storage_account_id = module.azure.storage_account_id
  search_endpoint_uri = module.azure.search_endpoint_uri
  dataverse_url = module.power-platform.dataverse_url
  search_api_key = module.azure.search_api_key
}