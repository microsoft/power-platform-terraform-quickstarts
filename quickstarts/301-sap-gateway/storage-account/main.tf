terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = ">=1.2.26"
    }
  }
}

resource "azurecaf_name" "storage_account_name" {
  name          = var.base_name
  resource_type = "azurerm_storage_account"
  prefixes      = [var.prefix]
  random_length = 3
  clean_input   = true
}

resource "azurerm_storage_account" "storage_account" {
  name                            = azurecaf_name.storage_account_name.result
  resource_group_name             = var.resource_group_name
  location                        = var.region
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  public_network_access_enabled   = true //this feature needs to be changed to be false once the setup is completed.
  allow_nested_items_to_be_public = true //this feature needs to be changed to be false once the setup is completed.
  shared_access_key_enabled       = true //this feature needs to be changed to be false once the setup is completed.

  identity {
    type = "SystemAssigned"
  }

  network_rules {
    default_action = "Allow" // this feature needs to be changed to be"Deny"
    bypass         = ["AzureServices", "Logging", "Metrics"]
  }

}

resource "azurerm_storage_container" "storage_container_installs" {
  name                  = "installs"
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "blob"
}

resource "azurerm_storage_blob" "storage_blob_ps7_setup" {
  name                   = "ps7-setup.ps1"
  storage_account_name   = azurerm_storage_account.storage_account.name
  storage_container_name = azurerm_storage_container.storage_container_installs.name
  type                   = "Block"
  source                 = "./storage-account/scripts/ps7-setup.ps1"
}

resource "azurerm_storage_blob" "storage_blob_java_runtime" {
  name                   = "java-runtime-setup.ps1"
  storage_account_name   = azurerm_storage_account.storage_account.name
  storage_container_name = azurerm_storage_container.storage_container_installs.name
  type                   = "Block"
  source                 = "./storage-account/scripts/java-setup.ps1"
}

resource "azurerm_storage_blob" "storage_blob_sapnco_install" {
  name                   = "sapnco.msi"
  storage_account_name   = azurerm_storage_account.storage_account.name
  storage_container_name = azurerm_storage_container.storage_container_installs.name
  type                   = "Block"
  source                 = "./storage-account/sapnco-msi/sapnco.msi"
}

resource "azurerm_storage_blob" "storage_blob_runtime_setup" {
  name                   = "runtime-setup.ps1"
  storage_account_name   = azurerm_storage_account.storage_account.name
  storage_container_name = azurerm_storage_container.storage_container_installs.name
  type                   = "Block"
  source                 = "./storage-account/scripts/runtime-setup.ps1"
}

### Loging for Storageaccount blob

resource "azurerm_log_analytics_workspace" "analytics_workspace_sapinteration" {
  name                = "sapintegration-workspace"
  location            = var.region
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
resource "azurerm_log_analytics_storage_insights" "analytics_storage_insights_sapintegration" {
  name                 = "sapintegration-storageinsightconfig"
  resource_group_name  = var.resource_group_name
  workspace_id         = azurerm_log_analytics_workspace.analytics_workspace_sapinteration.id
  storage_account_id   = azurerm_storage_account.storage_account.id
  storage_account_key  = azurerm_storage_account.storage_account.primary_access_key
  blob_container_names = [azurerm_storage_container.storage_container_installs.name]
}
