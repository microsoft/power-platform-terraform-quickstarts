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

data "azurerm_client_config" "current" {}

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
  account_replication_type        = "LRS" // GRS will be the recomended value for production 
  min_tls_version                 = "TLS1_2"
  public_network_access_enabled   = true  //this feature needs to be changed to be false once the setup is completed.
  allow_nested_items_to_be_public = false //this feature needs to be changed to be false once the setup is completed.
  shared_access_key_enabled       = false //this feature needs to be changed to be false once the setup is completed.
  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }
  # reading queue properties sends error after deploy the storage account 
  /* 
  queue_properties {
    logging {
      read                  = true
      write                 = true
      delete                = true
      version               = "1.0"
      retention_policy_days = 1
    }
    hour_metrics {
      enabled               = true
      include_apis          = true
      retention_policy_days = 1
      version               = "1.0"
    }
    minute_metrics {
      enabled               = true
      include_apis          = true
      retention_policy_days = 1
      version               = "1.0"
    }
  }
  */
  identity {
    type = "SystemAssigned"
  }
  network_rules {
    default_action = "Allow" // "Deny"
    bypass         = ["AzureServices", "Logging", "Metrics"]
  }

}



### encryption key for storage account
/*resource "azurerm_key_vault_access_policy" "client" {
  key_vault_id = var.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions = ["Get"]
}*/

resource "azurerm_key_vault_key" "storage_account_key" {
  name         = "tfex-key"
  key_vault_id = var.key_vault_id
  key_type     = "RSA-HSM"
  key_size     = 2048
  #  key_opts        = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  rotation_policy {
    automatic {
      time_before_expiry = "P30D"
    }

    expire_after         = "P90D"
    notify_before_expiry = "P29D"
  }
  expiration_date = "2024-12-30T20:00:00Z"
}

/*
resource "azurerm_role_assignment" "role_assignment_storagekv" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_storage_account.storage_account.id
}
*/
/*
resource "azurerm_role_assignment" "role_assignment_keyvault" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Reader"
  principal_id         = data.azurerm_client_config.current.object_id
}
*/


resource "azurerm_storage_account_customer_managed_key" "ok_cmk" {
  storage_account_id = azurerm_storage_account.storage_account.id
  key_vault_id       = var.key_vault_id
  key_name           = azurerm_key_vault_key.storage_account_key.name
}

### Storage container and blob
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
  name                 = "sapintegration-storageinsightconfig"
  resource_group_name  = var.resource_group_name
  workspace_id         = azurerm_log_analytics_workspace.analytics_workspace_sapinteration.id
  storage_account_id   = azurerm_storage_account.storage_account.id
  storage_account_key  = azurerm_storage_account.storage_account.primary_access_key
  blob_container_names = [azurerm_storage_container.storage_container_installs.name]
}

### Private endpoint for Storage Account

resource "azurerm_private_endpoint" "storage_account_pe" {
  name                = "${azurerm_storage_account.storage_account.name}-pe" #"${azurerm_storage_account.name}-pe"
  resource_group_name = var.resource_group_name
  location            = var.region
  subnet_id           = var.subnet_id
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = var.private_dns_zone_blob_id
  }
  private_service_connection {
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.storage_account.id
    name                           = "${azurerm_storage_account.storage_account.name}-psc"
    subresource_names              = ["blob"]
  }
  depends_on = [azurerm_storage_account.storage_account]
}
