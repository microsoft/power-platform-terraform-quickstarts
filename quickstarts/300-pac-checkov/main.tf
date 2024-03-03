terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.74.0"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = ">=1.2.26"
    }
  }
}


provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurecaf_name" "rg" {
  name          = var.base_name
  resource_type = "azurerm_resource_group"
  prefixes      = [var.prefix]
  random_length = 3
  clean_input   = true
}

resource "azurerm_resource_group" "rg" {
  name     = azurecaf_name.rg.result
  location = var.location
}

// The following section is commented with the objective of removing the comments and executing checkov,
// after executing it we can see the tool's alerts.

// Remove comments from the next section and run checkov to view and resolve the alerts.

/* 
resource "azurecaf_name" "storage_account_name" {
  name          = var.base_name
  resource_type = "azurerm_storage_account"
  prefixes      = [var.prefix]
  random_length = 3
  clean_input   = true
}

resource "azurerm_storage_account" "storage_account" {
  name                     = azurecaf_name.storage_account_name.result
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "storage_container_installs" {
  name                  = "installs"
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "blob"
}

*/