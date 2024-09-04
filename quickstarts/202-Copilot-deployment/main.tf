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

module "resource-names" {
  source = "./resource-names"
}

module "azure-control-plane" {
  source  = "./azure-control-plane"
  copilot_name = module.resource-names.copilot_name
  resource_group = module.resource-names.resource_group
  ai_search = module.resource-names.ai_search
  data_storage = module.resource-names.data_storage
  data_container = module.resource-names.data_container
}

module "azure-data-plane" {
  source = "./azure-data-plane"
  storage_container_name = module.azure-control-plane.storage_container_name
  storage_account_id = module.azure-control-plane.storage_account_id
  search_endpoint_uri = module.azure-control-plane.search_endpoint_uri
  search_api_key = module.azure-control-plane.search_api_key
  search_datasource_name = module.resource-names.ai_search_datasource
  storage_account_name = module.azure-control-plane.storage_account_name
  storage_account_key = module.azure-control-plane.storage_account_key
}

module "power-platform" {
  source = "./power-platform"
  environment_display_name = module.resource-names.power_platform-environment
  copilot_name = module.resource-names.copilot_name
  oai_resource_name = module.azure-control-plane.oai_resource_name
  oai_api_key = module.azure-control-plane.oai_api_key
  search_endpoint_uri = module.azure-control-plane.search_endpoint_uri
  search_api_key = module.azure-control-plane.search_api_key
}
