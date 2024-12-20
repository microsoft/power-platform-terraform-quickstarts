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

resource "azurecaf_name" "sig" {
  name          = var.base_name
  resource_type = "azurerm_shared_image_gallery"
  prefixes      = [var.prefix]
  random_length = 3
  clean_input   = true
}

resource "azurerm_shared_image_gallery" "sig" {
  name                = azurecaf_name.sig.result
  resource_group_name = var.resource_group_name
  location            = var.region
  tags                = var.tags
}

# Create PowerShell 7 version in Shared Image Gallery
module "ps7-setup" {
  source              = "./ps7-setup"
  prefix              = var.prefix
  base_name           = var.base_name
  resource_group_name = var.resource_group_name
  region              = var.region
  sig_id              = azurerm_shared_image_gallery.sig.id
  ps7_setup_link      = var.ps7_setup_link
}

# Create Java Runtime version in Shared Image Gallery
module "java-runtime-setup" {
  source              = "./java-runtime-setup"
  prefix              = var.prefix
  base_name           = var.base_name
  resource_group_name = var.resource_group_name
  region              = var.region
  sig_id              = azurerm_shared_image_gallery.sig.id
  java_setup_link     = var.java_setup_link

  depends_on = [module.ps7-setup]
}

# Create SAP NCo version in Shared Image Gallery
module "sapnco_install" {
  source              = "./sapnco-install"
  prefix              = var.prefix
  base_name           = var.base_name
  resource_group_name = var.resource_group_name
  region              = var.region
  sig_id              = azurerm_shared_image_gallery.sig.id
  sapnco_install_link = var.sapnco_install_link

  depends_on = [module.ps7-setup, module.java-runtime-setup]
}

# Install Script for Runtime configuration
module "runtime-setup" {
  source              = "./runtime-setup"
  prefix              = var.prefix
  base_name           = var.base_name
  resource_group_name = var.resource_group_name
  region              = var.region
  sig_id              = azurerm_shared_image_gallery.sig.id
  runtime_setup_link  = var.runtime_setup_link

  depends_on = [module.ps7-setup, module.java-runtime-setup, module.sapnco_install]
}

# There is an issue in the resource for naming Key Vaults that is preventing to proper naming
# Name and prefixes are not working properly, with random part
resource "random_string" "vm-opgw-suffix" {
  length  = 5
  upper   = false
  numeric = false
  special = false
}

#concatenate the base name with the random suffix
locals {
  vm_opgw_name = "${var.base_name}-${random_string.vm-opgw-suffix.result}"
}

resource "azurerm_windows_virtual_machine" "vm-opgw" {
  name                  = local.vm_opgw_name
  location              = var.region
  resource_group_name   = var.resource_group_name
  network_interface_ids = [var.nic_id]

  identity {
    type = "SystemAssigned"
  }

  # rest of the resource block
  size                                                   = "Standard_D4s_v5"
  admin_username                                         = var.vm_user
  admin_password                                         = var.vm_pwd
  computer_name                                          = "vmopgw"
  enable_automatic_updates                               = true
  bypass_platform_safety_checks_on_user_schedule_enabled = false
  patch_assessment_mode                                  = "ImageDefault"
  patch_mode                                             = "AutomaticByOS"
  encryption_at_host_enabled                             = var.encryption_at_host_enabled # "true" Enable encryption at host, need's to configure the disk encryption set
  #checkov:skip=CKV_AZURE_151:encryption_at_host_enabled is set to false do to we dont have permisions to enable that feature.
  allow_extension_operations = var.allow_extension_operations # "false" This feature needs to be turn to true to allow the VM to install extensions.
  #checkov:skip=CKV_AZURE_50:allow_extension_operations is set to false to install SAP SW.

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 128
    name                 = "myosdisk1"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-smalldisk"
    version   = "latest"
  }

  # Setup PowerShell 7
  gallery_application {
    version_id = module.ps7-setup.powershell_version_id
    order      = 1
  }

  # Setup Java Runtime
  gallery_application {
    version_id = module.java-runtime-setup.java_runtime_version_id
    order      = 2
  }

  # Install SAP NCo
  gallery_application {
    version_id = module.sapnco_install.sapnco_install_version_id
    order      = 3
  }

  # Setup Runtime configuration
  gallery_application {
    version_id = module.runtime-setup.runtime_version_id
    order      = 4
  }
  tags = var.tags
}

# Create a virtual machine extension to run the runtime-setup.ps1 script
# This script uses the VM Principal ID to access the Key Vault and retrieve the secrets
# VM Principal ID is only available after the VM is created
resource "azurerm_virtual_machine_extension" "runtime-setup" {
  name                 = "runtime-setup"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm-opgw.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
        "commandToExecute": "C:\\powershell7\\7\\pwsh.exe -ExecutionPolicy Unrestricted -command \"& {C:\\sapint\\runtime-setup.ps1 -keyVaultUri ${var.key_vault_uri} -secretNamePP ${var.secret_pp_name} -userAdmin ${var.user_id_admin_pp} -secretNameIRKey ${var.secret_name_irkey} -ApplicationId ${var.client_id_pp} -TenantId ${var.tenant_id_pp} -GatewayName ${var.gateway_name} -SecretNameRecoverKey ${var.secret_name_recover_key_gw} | Out-File -FilePath C:\\sapint\\runtime-out.txt}\""
    }
SETTINGS

  timeouts {
    create = "60m"
    delete = "60m"
  }
  tags = var.tags
}
