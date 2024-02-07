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
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = false
    }
  }
  client_id       = var.client_id_gw
  client_secret   = var.secret_gw
  tenant_id       = var.tenant_id_gw
  subscription_id = var.subscription_id_gw
}

data "azurerm_client_config" "current" {}

resource "azurecaf_name" "rg" {
  name          = var.base_name
  resource_type = "azurerm_resource_group"
  prefixes      = [var.prefix]
  random_length = 3
  clean_input   = true
}

resource "azurerm_resource_group" "rg" {
  name     = azurecaf_name.rg.result
  location = var.region_gw
}

resource "azurecaf_name" "vnet" {
  name          = var.base_name
  resource_type = "azurerm_virtual_network"
  prefixes      = [var.prefix]
  random_length = 3
  clean_input   = true
}

resource "azurerm_virtual_network" "vnet" {
  name                = azurecaf_name.vnet.result
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurecaf_name" "subnet" {
  name          = var.base_name
  resource_type = "azurerm_subnet"
  prefixes      = [var.prefix]
  random_length = 3
  clean_input   = true
}

resource "azurerm_subnet" "subnet" {
  name                 = azurecaf_name.subnet.result
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}
resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurecaf_name" "nsg" {
  name          = var.base_name
  resource_type = "azurerm_network_security_group"
  prefixes      = [var.prefix]
  random_length = 3
  clean_input   = true
}

resource "azurerm_network_security_group" "nsg" {
  name                = azurecaf_name.nsg.result
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurecaf_name" "publicip" {
  name          = var.base_name
  resource_type = "azurerm_public_ip"
  prefixes      = [var.prefix]
  random_length = 3
  clean_input   = true
}

resource "azurerm_public_ip" "publicip" {
  name                = azurecaf_name.publicip.result
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

resource "azurecaf_name" "nic" {
  name          = var.base_name
  resource_type = "azurerm_network_interface"
  prefixes      = [var.prefix]
  random_length = 3
  clean_input   = true
}

resource "azurerm_network_interface" "nic" {
  name                = azurecaf_name.nic.result
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.sap_subnet_id
    private_ip_address_allocation = "Dynamic"
    # public_ip_address_id          = azurerm_public_ip.publicip.id # Uncomment this line to assign a public IP to make the VM accessible from the internet
  }

}

resource "azurerm_network_interface_security_group_association" "rgassociation" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "random_string" "key_vault_suffix" {
  length  = 3
  upper   = false
  numeric = false
  special = false
}

# There is an issue in the resource for naming Key Vaults that is preventing to proper naming
# Name and prefixes are not working properly, with random part
resource "azurecaf_name" "key_vault" {
  name          = var.prefix
  resource_type = "azurerm_key_vault"
  random_length = 9
  clean_input   = true
}

resource "azurerm_key_vault" "key_vault" {
  name                          = azurecaf_name.key_vault.result
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  tenant_id                     = var.tenant_id_gw
  sku_name                      = "standard"
  public_network_access_enabled = false # Checov requirement verify if it is needed
  purge_protection_enabled      = true
  soft_delete_retention_days    = 7

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  access_policy {
    tenant_id = var.tenant_id_gw
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "List",
      "Delete",
      "Set",
      "Purge",
    ]
  }
}

### encryption key for storage account
data "azurerm_client_config" "current" {}
resource "azurerm_key_vault_access_policy" "client" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify"]
  secret_permissions = ["Get"]
}

resource "azurerm_key_vault_key" "storage_account_key" {
  name         = "tfex-key"
  key_vault_id = azurerm_key_vault.key_vault.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]

  depends_on = [
    azurerm_key_vault_access_policy.client
  ]
}

resource "azurerm_storage_account_customer_managed_key" "ok_cmk" {
  storage_account_id = module.storage_account.storage_account_id
  key_vault_id       = azurerm_key_vault.key_vault.id
  key_name           = azurerm_key_vault_key.storage_account_key.name
}

resource "azurecaf_name" "key_vault_secret_pp" {
  name          = "pp"
  resource_type = "azurerm_key_vault_secret"
  prefixes      = [var.prefix]
  random_length = 3
  clean_input   = true
}

resource "azurerm_key_vault_secret" "key_vault_secret_pp" {
  name            = azurecaf_name.key_vault_secret_pp.result
  value           = var.secret_pp
  key_vault_id    = azurerm_key_vault.key_vault.id
  expiration_date = "2024-12-30T20:00:00Z"
  content_type    = "text/plain"
}

resource "azurecaf_name" "key_vault_secret_irkey" {
  name          = "irkey"
  resource_type = "azurerm_key_vault_secret"
  prefixes      = [var.prefix]
  random_length = 3
  clean_input   = true
}

resource "azurerm_key_vault_secret" "key_vault_secret_irkey" {
  name            = azurecaf_name.key_vault_secret_irkey.result
  value           = var.ir_key
  key_vault_id    = azurerm_key_vault.key_vault.id
  expiration_date = "2024-12-30T20:00:00Z"
  content_type    = "text/plain"
}

resource "azurecaf_name" "key_vault_secret_recover_key" {
  name          = "recoverkey"
  resource_type = "azurerm_key_vault_secret"
  prefixes      = [var.prefix]
  random_length = 3
  clean_input   = true
}

resource "azurerm_key_vault_secret" "key_vault_secret_recover_key" {
  name            = azurecaf_name.key_vault_secret_recover_key.result
  value           = var.recover_key_gw
  key_vault_id    = azurerm_key_vault.key_vault.id
  expiration_date = "2024-12-30T20:00:00Z"
  content_type    = "text/plain"
}

resource "random_string" "vm_pwd" {
  length  = 32
  special = true
  numeric = true
}

resource "azurecaf_name" "key_vault_secret_vm_pwd" {
  name          = "vm-pwd"
  resource_type = "azurerm_key_vault_secret"
  prefixes      = [var.prefix]
  random_length = 3
  clean_input   = true
}

resource "azurerm_key_vault_secret" "key_vault_secret_vm_pwd" {
  name            = azurecaf_name.key_vault_secret_vm_pwd.result
  value           = random_string.vm_pwd.result
  key_vault_id    = azurerm_key_vault.key_vault.id
  expiration_date = "2024-12-30T20:00:00Z"
  content_type    = "text/plain"
}

module "storage_account" {
  source                   = "./storage-account"
  prefix                   = var.prefix
  base_name                = var.base_name
  resource_group_name      = azurerm_resource_group.rg.name
  region                   = var.region_gw
  subnet_id                = azurerm_subnet.subnet.id
  private_dns_zone_blob_id = [azurerm_private_dns_zone.private_dns_zones["privatelink-blob-core-windows-net"].id]
}

module "gateway_vm" {
  source                     = "./gateway-vm"
  resource_group_name        = azurerm_resource_group.rg.name
  base_name                  = var.base_name
  region                     = var.region_gw
  vm_pwd                     = random_string.vm_pwd.result
  nic_id                     = azurerm_network_interface.nic.id
  client_id_pp               = var.client_id_pp
  tenant_id_pp               = var.tenant_id_pp
  key_vault_uri              = azurerm_key_vault.key_vault.vault_uri
  secret_pp_name             = azurerm_key_vault_secret.key_vault_secret_pp.name
  secret_name_irkey          = azurerm_key_vault_secret.key_vault_secret_irkey.name
  user_id_admin_pp           = var.user_id_admin_pp
  ps7_setup_link             = module.storage_account.storage_blob_ps7_setup_link
  java_setup_link            = module.storage_account.storage_blob_java_runtime_link
  sapnco_install_link        = module.storage_account.storage_blob_sapnco_install_link
  runtime_setup_link         = module.storage_account.storage_blob_runtime_setup_link
  gateway_name               = var.gateway_name
  secret_name_recover_key_gw = azurerm_key_vault_secret.key_vault_secret_recover_key.name
}

resource "azurerm_key_vault_access_policy" "key_vault_access_policy" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = var.tenant_id_gw
  object_id    = module.gateway_vm.vm_opgw_principal_id
  secret_permissions = [
    "Get",
    "List",
  ]
}

# Private DNS zones for Azure services
locals {
  private_dns_zones = {
    privatelink-blob-core-windows-net = "privatelink.blob.core.windows.net"
    privatelink-vaultcore-azure-net   = "privatelink.vaultcore.azure.net"
  }
}

resource "azurerm_private_dns_zone" "private_dns_zones" {
  for_each            = local.private_dns_zones
  name                = each.value
  resource_group_name = azurerm_resource_group.rg.name
}

### Private dns links
resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_network_links" {
  for_each              = local.private_dns_zones
  name                  = "${azurerm_virtual_network.vnet.name}-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = each.value
  virtual_network_id    = azurerm_virtual_network.vnet.id
  depends_on            = [azurerm_private_dns_zone.private_dns_zones]
}
### Private endpoint for Key Vault
resource "azurerm_private_endpoint" "key_vault_pe" {
  name                = "${azurerm_key_vault.key_vault.name}-pe"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  subnet_id           = azurerm_subnet.subnet.id
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.private_dns_zones["privatelink-vaultcore-azure-net"].id]
  }
  private_service_connection {
    is_manual_connection           = false
    private_connection_resource_id = azurerm_key_vault.key_vault.id
    name                           = "${azurerm_key_vault.key_vault.name}-psc"
    subresource_names              = ["vault"]
  }
  depends_on = [azurerm_key_vault.key_vault]
}

### review if it is required
/*resource "azurerm_role_assignment" "terraform_spn" {
  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}
*/