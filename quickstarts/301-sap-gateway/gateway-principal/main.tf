terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    azuread = {
      source = "hashicorp/azuread"
    }
  }
}

provider "azuread" {
}

data "azuread_application_published_app_ids" "well_known" {

}

data "azuread_service_principal" "powerbi" {
  client_id = data.azuread_application_published_app_ids.well_known.result.PowerBiService
  #use_existing   = true
}

resource "azuread_application" "gateway_application" {
  display_name = "Gateway Application"

  required_resource_access {
    resource_app_id = data.azuread_application_published_app_ids.well_known.result.PowerBiService

    resource_access {
      id   = data.azuread_service_principal.powerbi.app_role_ids["Tenant.Read.All"]
      type = "Role"
    }

    resource_access {
      id   = data.azuread_service_principal.powerbi.app_role_ids["Tenant.ReadWrite.All"]
      type = "Role"
    }
  }
}

resource "azuread_service_principal" "gateway_principal" {
  client_id   = azuread_application.gateway_application.client_id
  description = "Gateway Principal"
}

resource "azuread_service_principal_password" "gateway_principal_password" {
  service_principal_id = azuread_service_principal.gateway_principal.id
}
