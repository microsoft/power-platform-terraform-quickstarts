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
    github = {
      source = "integrations/github"
    }
  }

  backend "azurerm" {
    container_name = "tfstate"
    key            = "tenant-configuration.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

provider "github" {
  owner = "commercial-software-engineering" //HACK: This is a workaround for a bug in the GitHub provider https://github.com/integrations/terraform-provider-github/issues/1471
}

# Get a reference to the current Azure AD configuration so that we can read the tenant ID
data "azuread_client_config" "current" {}

data "azurerm_subscription" "current" {
}

# Get a reference to the Power Platform API's pre-existing service principal
resource "azuread_service_principal" "power_platform_api" {
  client_id = var.client_id // Power Platform API
  use_existing   = true
}

# Create a new Entra ID (Azure AD) application for the Power Platform Admin Service.  This is
# the service account that will be used to apply terraform modules in the GitHub Actions workflow.
resource "azuread_application" "ppadmin_application" {
  display_name = "Power Platform Admin Service"
  owners       = [data.azuread_client_config.current.object_id]

  required_resource_access {
    resource_app_id = resource.azuread_service_principal.power_platform_api.application_id

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
}

# Create a service principal for the Power Platform Admin Service application
resource "azuread_service_principal" "ppadmin_principal" {
  client_id               = azuread_application.ppadmin_application.client_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
}

# Create a client secret for the Power Platform Admin Service application
resource "azuread_application_password" "ppadmin_secret" {
  application_id = azuread_application.ppadmin_application.application_id
}

data "azurerm_storage_account" "tf_state_storage_account" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

# Grant the Power Platfom Admin Service Storage Blob Contributor role on the Terraform state storage account
resource "azurerm_role_assignment" "ppadmin_storage_role_assignment" {
  scope                = data.azurerm_storage_account.tf_state_storage_account.id
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

# Grant the Power Platform Admin Service application the permissions it needs to manage Power Platform via the BAPI APIs
resource "null_resource" "ppadmin_role_assignment" {
  triggers = {
    client_id = azuread_application.ppadmin_application.application_id
  }
  provisioner "local-exec" {
    when    = create
    command = "${path.module}/grant-ppadmin.sh --client_id ${self.triggers.client_id} --action create"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "${path.module}/grant-ppadmin.sh --client_id ${self.triggers.client_id} --action destroy"
  }
}

# Get a reference to the GitHub repository that will be used to store the GitHub Actions workflow
data "github_repository" "quickstarts" {
  full_name = var.github_repo
}

# Save the service principal information in GitHub Actions secrets/variables
# resource "github_actions_secret" "client_secret" {
#   repository      = data.github_repository.quickstarts.name
#   secret_name     = "PPADMIN_CLIENT_SECRET"
#   plaintext_value = azuread_application_password.ppadmin_secret.value
# }

# resource "github_actions_variable" "client_id" {
#   repository    = data.github_repository.quickstarts.name
#   variable_name = "PPADMIN_CLIENT_ID"
#   value         = azuread_application.ppadmin_application.application_id
# }

# resource "github_actions_variable" "subscription_id" {
#   repository    = data.github_repository.quickstarts.name
#   variable_name = "PPADMIN_SUBSCRIPTION_ID"
#   value         = data.azurerm_subscription.current.subscription_id
# }

# resource "github_actions_variable" "tenant_id" {
#   repository    = data.github_repository.quickstarts.name
#   variable_name = "PPADMIN_TENANT_ID"
#   value         = data.azuread_client_config.current.tenant_id
# }

# # Save the terraform state storage account name in GitHub Actions variables
# resource "github_actions_variable" "tf_state_storage_account_name" {
#   repository    = data.github_repository.quickstarts.name
#   variable_name = "TF_STATE_STORAGE_ACCOUNT_NAME"
#   value         = var.storage_account_name
# }

# resource "github_actions_variable" "tf_state_resource_group_name" {
#   repository    = data.github_repository.quickstarts.name
#   variable_name = "TF_STATE_RESOURCE_GROUP_NAME"
#   value         = var.resource_group_name
# }