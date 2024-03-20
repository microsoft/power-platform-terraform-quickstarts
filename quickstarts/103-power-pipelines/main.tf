terraform {
  required_providers {
    azuread = {
      source = "hashicorp/azuread"
    }
    random = {
      source = "hashicorp/random"
    }
    null = {
      source = "hashicorp/null"
    }
    powerplatform = {
      source  = "microsoft/power-platform"
      version = "0.7.0-preview"
    }
  }
}

provider "powerplatform" {
  use_cli = true
}
data "azuread_group" "developer_group" {
    object_id = var.developer_group
}

resource "powerplatform_environment" "pipeline_host" {
  location          = "unitedstates"
  language_code     = 1033
  display_name      = "QuickstartPipelineHost"
  currency_code     = "USD"
  environment_type  = "Production"
  security_group_id = data.azuread_group.developer_group.id
  billing_policy_id    = "d8255a99-ad4e-4cf9-963f-870d70843fa9"
}

resource "powerplatform_environment" "dev" {
  location          = "unitedstates"
  language_code     = 1033
  display_name      = "${var.app_name} Dev"
  currency_code     = "USD"
  environment_type  = "Sandbox"
  security_group_id = data.azuread_group.developer_group.id
  billing_policy_id    = "d8255a99-ad4e-4cf9-963f-870d70843fa9"
}

resource "powerplatform_environment" "uat" {
  location          = "unitedstates"
  language_code     = 1033
  display_name      = "${var.app_name} UAT"
  currency_code     = "USD"
  environment_type  = "Production"
  security_group_id = data.azuread_group.developer_group.id
  billing_policy_id    = "d8255a99-ad4e-4cf9-963f-870d70843fa9"
}

resource "powerplatform_environment" "prod" {
  location          = "unitedstates"
  language_code     = 1033
  display_name      = var.app_name
  currency_code     = "USD"
  environment_type  = "Production"
  security_group_id = data.azuread_group.developer_group.id
  billing_policy_id    = "d8255a99-ad4e-4cf9-963f-870d70843fa9"
}

resource "powerplatform_managed_environment" "prod_managed" {
    environment_id = powerplatform_environment.prod.id
    is_usage_insights_disabled = true
    is_group_sharing_disabled  = true
    limit_sharing_mode         = "ExcludeSharingToSecurityGroups"
    max_limit_user_sharing     = 10
    solution_checker_mode      = "None"
    suppress_validation_emails = true
    maker_onboarding_markdown  = "Welcome to the ${powerplatform_environment.prod.display_name} environment!"
    maker_onboarding_url       = "https://www.contoso.com/onboarding"
}

data "powerplatform_applications" "pipelines_application_definition" {
    environment_id = powerplatform_environment.pipeline_host.id
    name           = "Power Platform Pipelines"
    publisher_name = "Microsoft Dynamics 365"
}

resource "powerplatform_application" "pipelines_installation" {
    environment_id = powerplatform_environment.pipeline_host.id
    unique_name = data.powerplatform_applications.pipelines_application_definition.applications[0].unique_name
}
