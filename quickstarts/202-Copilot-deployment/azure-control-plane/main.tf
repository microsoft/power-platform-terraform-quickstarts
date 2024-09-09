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
  //TODO public network access needs to be off
  public_network_access_enabled = true
  deployment = local.deployment_map[var.openai_environment]
  depends_on = [azurerm_resource_group.Copilot-Deployment-Quickstart-RG]
}

#---- 3 - Create storage and search resources ----
# To be connected to the model in the Power Platform module

data "azurerm_client_config" "current" {}

#Key Vault
#TODO: This is a stub, needs to be updated for AIRI resource
# resource "azurerm_key_vault" "placeholder_key_vault" {
#   name                = var.placeholder_keyvault_name
#   location            = azurerm_resource_group.Copilot-Deployment-Quickstart-RG.location
#   resource_group_name = azurerm_resource_group.Copilot-Deployment-Quickstart-RG.name
#   sku_name            = "standard"
#   tenant_id           = data.azurerm_client_config.current.tenant_id
#   purge_protection_enabled = true
#   //TODO public network access needs to be off
#   public_network_access_enabled = true
#   network_acls {
#     default_action = "Deny"
#     bypass = "AzureServices"
#     #ip_rules = ["1.1.1.1"]
#   }
# }

#KV Access Policy
#TODO: This is a stub, needs to be updated for AIRI resource
# resource "azurerm_key_vault_access_policy" "placeholder_kv_access_policy" {
#   key_vault_id = azurerm_key_vault.placeholder_key_vault.id
#   tenant_id    = data.azurerm_client_config.current.tenant_id
#   object_id    = data.azurerm_client_config.current.object_id

#   key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
#   secret_permissions = ["Get"]
# }

#Key
#TODO: This is a stub, needs to be updated for AIRI resource
# resource "azurerm_key_vault_key" "placeholder_kv_key" {
#   name         = "tfex-key"
#   key_vault_id = azurerm_key_vault.placeholder_key_vault.id
#   key_type     = "RSA-HSM"
#   key_size     = 2048
#   key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]

#   depends_on = [
#     azurerm_key_vault_access_policy.placeholder_kv_access_policy
#   ]

#   expiration_date = timeadd(formatdate("YYYY-MM-01'T'00:00:00Z", timestamp()), "2160h") # 90 days
# }

#Managed Key
#TODO: This is a stub, needs to be updated for AIRI resource
# resource "azurerm_storage_account_customer_managed_key" "placeholder_cmk" {
#   storage_account_id = azurerm_storage_account.Quickstart-Data-Storage.id
#   key_vault_id       = azurerm_key_vault.placeholder_key_vault.id
#   key_name           = azurerm_key_vault_key.placeholder_kv_key.name
# }


# Storage account
resource "azurerm_storage_account" "Quickstart-Data-Storage" {
  name                     = var.data_storage
  resource_group_name      = azurerm_resource_group.Copilot-Deployment-Quickstart-RG.name
  location                 = var.azure_location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  min_tls_version          = "TLS1_2"
  # TODO: Public network access needs to be turned off
  public_network_access_enabled = true
  allow_nested_items_to_be_public = true
  #shared_access_key_enabled = false
  queue_properties  {
    logging {
        delete                = true
        read                  = true
        write                 = true
        version               = "1.0"
        retention_policy_days = 14
    }
  }
  blob_properties {
    delete_retention_policy {
       days = 14
    }
  }
  sas_policy {
    expiration_period = "90.00:00:00"
    expiration_action = "Log"
  }
}

#Virtual Network
#TODO: This is a stub, needs to be updated for AIRI resource
resource "azurerm_virtual_network" "placeholder_virtual_network" {
  name                = "placeholder-example-vnet"
  location            = azurerm_resource_group.Copilot-Deployment-Quickstart-RG.location
  resource_group_name = azurerm_resource_group.Copilot-Deployment-Quickstart-RG.name
  address_space       = ["10.0.0.0/16"]
}

#Subnet
#TODO: This is a stub, needs to be updated for AIRI resource
resource "azurerm_subnet" "placeholder_subnet" {
  name = "placeholder_example_private_endpoint"
  resource_group_name  = azurerm_resource_group.Copilot-Deployment-Quickstart-RG.name
  virtual_network_name = azurerm_virtual_network.placeholder_virtual_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

#Network Security Group and association
#TODO: This is a stub, needs to be updated for AIRI resource
resource "azurerm_network_security_group" "placeholder_nsg" {
  name                = "placeholder-nsg"
  location            = azurerm_resource_group.Copilot-Deployment-Quickstart-RG.location
  resource_group_name = azurerm_resource_group.Copilot-Deployment-Quickstart-RG.name
}

resource "azurerm_subnet_network_security_group_association" "placeholder_nsg_association" {
  subnet_id                 = azurerm_subnet.placeholder_subnet.id
  network_security_group_id = azurerm_network_security_group.placeholder_nsg.id
}

#Private endpoint
#TODO: This is a stub, needs to be updated for AIRI resource
# resource "azurerm_private_endpoint" "placeholder_private_endpoint" {
#   name                 = "placeholder_example_private_endpoint"
#   location             = azurerm_storage_account.Quickstart-Data-Storage.location
#   resource_group_name  = azurerm_resource_group.Copilot-Deployment-Quickstart-RG.name
#   subnet_id            = azurerm_subnet.placeholder_subnet.id

#   private_service_connection {
#     name                           = "placeholder_example_psc"
#     is_manual_connection           = false
#     private_connection_resource_id = azurerm_key_vault.placeholder_key_vault.id
#     subresource_names              = ["vault"]
#   }
# }

#Log analytics workspace
#TODO: This is a stub, needs to be updated for AIRI resource
resource "azurerm_log_analytics_workspace" "placeholder_analytics_workspace" {
  name                = "placeholder-analytics-workspace"
  location            = azurerm_resource_group.Copilot-Deployment-Quickstart-RG.location
  resource_group_name = azurerm_resource_group.Copilot-Deployment-Quickstart-RG.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# resource "azurerm_log_analytics_storage_insights" "placeholder_analytics_storage_insights" {
#   name                = "placeholder-storageinsightconfig"
#   resource_group_name = azurerm_resource_group.Copilot-Deployment-Quickstart-RG.name
#   workspace_id        = azurerm_log_analytics_workspace.placeholder_analytics_workspace.id

#   storage_account_id  = azurerm_storage_account.Quickstart-Data-Storage.id
#   storage_account_key = azurerm_storage_account.Quickstart-Data-Storage.primary_access_key
#   blob_container_names= ["blobExample_ok"]
# }

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
  sku                 = "standard"
  #replica_count = 3
  //TODO public network access needs to be off
  #public_network_access_enabled = true
  //TODO re-add system-assigned managed identity
  # identity {
  #   type = "SystemAssigned"
  # }
}