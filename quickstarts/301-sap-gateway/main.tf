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
      recover_soft_deleted_key_vaults = true
    }
  }
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
  tags     = var.tags
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
  tags                = var.tags
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
  virtual_network_name = azurerm_virtual_network.vnet.name #
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
  tags                = var.tags
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
    subnet_id                     = var.sap_subnet_id # azurerm_subnet.subnet.id change this value if you want to deploy the gateway in a different subnet
    private_ip_address_allocation = "Dynamic"
    # public_ip_address_id          = azurerm_public_ip.publicip.id # Uncomment this line to assign a public IP to make the VM accessible from the internet
  }
  tags = var.tags
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
  sku_name                      = "premium"
  public_network_access_enabled = true # Checov requires "false" , If you deploy from a dev vm that vm or agent needs to be on the same vnet or vnets with connectivity
  purge_protection_enabled      = true
  soft_delete_retention_days    = 7
  enabled_for_disk_encryption   = true
  enable_rbac_authorization     = false # Checkov requires "true"

  network_acls {
    default_action = "Allow" #Checkov requires "Deny"
    bypass         = "AzureServices"
    #checkov:skip=CKV_AZURE_109: This keyVault is not intended to be accessed from on-premises networks
    #checkov:skip=CKV_AZURE_189: "This deployment requires Azure Key Vault disables public network access"
    #checkov:skip=CKV2_AZURE_32: "Ensure private endpoint is configured to key vault, this deployment requires public access to the key vault"
  }


  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id


    secret_permissions = ["Get", "List", "Delete", "Set", "Purge"]
    key_permissions    = ["Get", "Create", "Delete", "List", "Restore", "Recover", "UnwrapKey", "WrapKey", "Purge", "Encrypt", "Decrypt", "Sign", "Verify", "Update", "GetRotationPolicy", "SetRotationPolicy"]
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = module.gateway_vm.vm_opgw_principal_id

    secret_permissions = ["Get", "List"]
    key_permissions    = ["Get", "List"]
  }
  tags = var.tags
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
  tags            = var.tags
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
  value           = var.shir_key
  key_vault_id    = azurerm_key_vault.key_vault.id
  expiration_date = "2024-12-30T20:00:00Z"
  content_type    = "text/plain"
  tags            = var.tags
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
  tags            = var.tags
}

resource "random_string" "vm_user" {
  length  = 20 # minimum 1, maximum 20
  special = false
  numeric = true
}

resource "azurecaf_name" "key_vault_secret_vm_user" {
  name          = "vm-user"
  resource_type = "azurerm_key_vault_secret"
  prefixes      = [var.prefix]
  random_length = 3
  clean_input   = true
}

resource "azurerm_key_vault_secret" "key_vault_secret_vm_user" {
  name            = azurecaf_name.key_vault_secret_vm_user.result
  value           = random_string.vm_user.result
  key_vault_id    = azurerm_key_vault.key_vault.id
  expiration_date = "2024-12-30T20:00:00Z"
  content_type    = "text/plain"
  tags            = var.tags
}

resource "random_string" "vm_pwd" {
  length  = 64
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
  tags            = var.tags
}

module "storage_account" {
  source              = "./storage-account"
  prefix              = var.prefix
  base_name           = var.base_name
  resource_group_name = azurerm_resource_group.rg.name
  region              = var.region_gw
}

module "gateway_vm" {
  source                     = "./gateway-vm"
  resource_group_name        = azurerm_resource_group.rg.name
  base_name                  = var.base_name
  region                     = var.region_gw
  vm_user                    = random_string.vm_user.result
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
