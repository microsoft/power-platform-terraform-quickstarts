terraform {
  required_providers {
    azuread = {
      source = "hashicorp/azuread"
    }
    azurerm = {
      source = "hashicorp/azurerm"
    }
    random = {
      source = "hashicorp/random"
    }
    null = {
      source = "hashicorp/null"
    }
  }

backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

provider "azuread" {
}

# Get a reference to the current Azure AD configuration so that we can read the tenant ID
data "azuread_client_config" "current" {}

data "azurerm_subscription" "current" {
}

# Get a reference to the Power Platform API's pre-existing service principal
resource "azuread_service_principal" "power_platform_api" {
  client_id    = "8578e004-a5c6-46e7-913e-12f58912df43" // Power Platform API
  use_existing = true
}

#get a reference to the PowerApps service principal
resource "azuread_service_principal" "powerapps_service" {
  client_id    = "475226c6-020e-4fb2-8a90-7a972cbfc1d4"
  use_existing = true
}

#get a reference to the Dynamics CRM service principal
resource "azuread_service_principal" "dynamics_service" {
  client_id    = "00000007-0000-0000-c000-000000000000"
  use_existing = true
}

# Create a new Entra ID (Azure AD) application for the Power Platform Admin Service.  This is
# the service account that will be used to apply terraform modules in the GitHub Actions workflow.
resource "azuread_application" "ppadmin_application" {
  display_name = "Power Platform Admin Service"
  owners       = [data.azuread_client_config.current.object_id]



  required_resource_access {
    resource_app_id = resource.azuread_service_principal.power_platform_api.client_id

    resource_access {
      id   = resource.azuread_service_principal.power_platform_api.oauth2_permission_scope_ids["Licensing.BillingPolicies.ReadWrite"]
      type = "Scope"
    }

    resource_access {
      id   = resource.azuread_service_principal.power_platform_api.oauth2_permission_scope_ids["Licensing.BillingPolicies.Read"]
      type = "Scope"
    }

    resource_access {
      id   = resource.azuread_service_principal.power_platform_api.oauth2_permission_scope_ids["AppManagement.ApplicationPackages.Install"]
      type = "Scope"
    }

    resource_access {
      id   = resource.azuread_service_principal.power_platform_api.oauth2_permission_scope_ids["AppManagement.ApplicationPackages.Read"]
      type = "Scope"
    }
  }

  required_resource_access {
    resource_app_id = resource.azuread_service_principal.powerapps_service.client_id
    resource_access {
      id   = resource.azuread_service_principal.powerapps_service.oauth2_permission_scope_ids["User"]
      type = "Scope"
    }
  }

  required_resource_access {
    resource_app_id = resource.azuread_service_principal.dynamics_service.client_id
    resource_access {
      id   = resource.azuread_service_principal.dynamics_service.oauth2_permission_scope_ids["user_impersonation"]
      type = "Scope"
    }

  }

  identifier_uris = ["api://power-platform_provider_terraform"]

  api {

    oauth2_permission_scope {
      admin_consent_description  = "Allows connection to backend services of Power Platform Terraform Provider"
      admin_consent_display_name = "Power Platform Terraform Provider Access"
      enabled                    = true
      id                         = "2aedce72-ddc7-431d-920c-a321297ffdc2"
      type                       = "User"
      user_consent_description   = "Allows connection to backend services of Power Platform Terraform Provider"
      user_consent_display_name  = "Power Platform Terraform Provider Access"
      value                      = "user_impersonation"
    }
  }


}

resource "azuread_application_pre_authorized" "ppadmin_application_allow_azure_cli" {
  application_id       = azuread_application.ppadmin_application.id
  authorized_client_id = "04b07795-8ddb-461a-bbee-02f9e1bf7b46" //Azure CLI first party application ID

  permission_ids = [
    "2aedce72-ddc7-431d-920c-a321297ffdc2",
  ]
}

# Create a service principal for the Power Platform Admin Service application
resource "azuread_service_principal" "ppadmin_principal" {
  client_id                    = azuread_application.ppadmin_application.client_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
}

# Create a client secret for the Power Platform Admin Service application
resource "azuread_application_password" "ppadmin_secret" {
  application_id = azuread_application.ppadmin_application.id
}

data "azurerm_storage_account" "tf_state_storage_account" {
  count               = var.storage_account_name != "<default>" ? 1 : 0
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

# Grant the Power Platfom Admin Service Storage Blob Contributor role on the Terraform state storage account
resource "azurerm_role_assignment" "ppadmin_storage_role_assignment" {
  count                = var.storage_account_name != "<default>" ? 1 : 0
  scope                = data.azurerm_storage_account.tf_state_storage_account[count.index].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.ppadmin_principal.object_id
}

data "azurerm_role_definition" "contributor" {
  name = "Contributor"
}

# Grant the Power Platfom Admin Service SContributor role on the Azure Subscription
resource "azurerm_role_assignment" "ppadmin_subscription_role_assignment" {
  scope              = data.azurerm_subscription.current.id
  role_definition_id = data.azurerm_role_definition.contributor.id
  principal_id       = azuread_service_principal.ppadmin_principal.object_id
}

#Grant the Power Platform Admin Service application the permissions it needs to manage Power Platform via the BAPI APIs
resource "null_resource" "ppadmin_role_assignment" {
  triggers = {
    client_id = azuread_application.ppadmin_application.client_id
  }
  provisioner "local-exec" {
    when    = create
    command = "${path.module}/grant-ppadmin.ps1 --client_id ${self.triggers.client_id} --action create"
    interpreter = ["pwsh", "-Command"]
  }
  provisioner "local-exec" {
    when    = destroy
    command = "${path.module}/grant-ppadmin.ps1 --client_id ${self.triggers.client_id} --action destroy"
    interpreter = ["pwsh", "-Command"]
  }
}
