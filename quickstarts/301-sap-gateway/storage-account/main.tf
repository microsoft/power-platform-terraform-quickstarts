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
  #checkov:skip=CKV_AZURE_33:The Storage Account dont use Queue service and is bloqued by the following network_rules block
  name                     = azurecaf_name.storage_account_name.result
  resource_group_name      = var.resource_group_name
  location                 = var.region
  account_tier             = "Standard"
  account_replication_type = "GRS"
  min_tls_version          = "TLS1_2"
  public_network_access_enabled = false
  allow_nested_items_to_be_public = false
  shared_access_key_enabled = false
  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }
  queue_properties {
    logging {
      read   = true
      write  = true
      delete = true
      version = "1.0"
      retention_policy_days = 1
    }
    hour_metrics {
      enabled = true
      include_apis = true
      retention_policy_days = 1
      version = "1.0"
    }
    minute_metrics {
      enabled = true
      include_apis = true
      retention_policy_days = 1
      version = "1.0"
    }
    }
  identity {
    type = "SystemAssigned"
  }
  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices", "Logging", "Metrics"]
  }

}


resource "azurerm_storage_container" "storage_container_installs" {
  name                  = "installs"
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "storage_blob_ps7_setup" {
  name                   = "ps7-setup.ps1"
  storage_account_name   = azurerm_storage_account.storage_account.name
  storage_container_name = azurerm_storage_container.storage_container_installs.name
  type                   = "Block"
  source                 = "/workspaces/terraform-provider-power-platform/examples/quickstarts/301-sap-gateway/storage-account/scripts/ps7-setup.ps1"
}

resource "azurerm_storage_blob" "storage_blob_java_runtime" {
  name                   = "java-runtime-setup.ps1"
  storage_account_name   = azurerm_storage_account.storage_account.name
  storage_container_name = azurerm_storage_container.storage_container_installs.name
  type                   = "Block"
  source                 = "/workspaces/terraform-provider-power-platform/examples/quickstarts/301-sap-gateway/storage-account/scripts/java-setup.ps1"
}

resource "azurerm_storage_blob" "storage_blob_sapnco_install" {
  name                   = "sapnco.msi"
  storage_account_name   = azurerm_storage_account.storage_account.name
  storage_container_name = azurerm_storage_container.storage_container_installs.name
  type                   = "Block"
  source                 = "/workspaces/terraform-provider-power-platform/examples/quickstarts/301-sap-gateway/storage-account/sapnco-msi/sapnco.msi"
}

resource "azurerm_storage_blob" "storage_blob_runtime_setup" {
  name                   = "runtime-setup.ps1"
  storage_account_name   = azurerm_storage_account.storage_account.name
  storage_container_name = azurerm_storage_container.storage_container_installs.name
  type                   = "Block"
  source                 = "/workspaces/terraform-provider-power-platform/examples/quickstarts/301-sap-gateway/storage-account/scripts/runtime-setup.ps1"
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
  name                = "sapintegration-storageinsightconfig"
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.analytics_workspace_sapinteration.id
  storage_account_id  = azurerm_storage_account.storage_account.id
  storage_account_key = azurerm_storage_account.storage_account.primary_access_key
  blob_container_names= [azurerm_storage_container.storage_container_installs.name]
}
