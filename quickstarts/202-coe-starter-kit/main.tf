terraform {
  required_providers {
    powerplatform = {
      source = "microsoft/power-platform"
      version = "2.4.1-preview"
    }
  }
}

provider "powerplatform" {
  use_cli = true
}

module "helpers" {
  source  = "./helpers"
  parameters = {
    env = {
      env_id = powerplatform_environment.coe-kit-prod.id
    }
    core = {
      admin_AuditLogsClientAzureSecret = var.core_components_parameters.admin_AuditLogsClientAzureSecret
    }
  }
}

//find creator kit in appsource
data "powerplatform_tenant_application_packages" "creator_kit_app" {
  publisher_name = "Microsoft Corp - Power CAT"
  name           = "Creator Kit"
}

//install the creator kit in coe-kit-prod environment (todo install in coe-kit-test)
//TODO: creator kit is not available in appsource in every region, consider using offline install
//https://learn.microsoft.com/en-us/power-platform/guidance/creator-kit/setup#option-1-manually-install-the-solutions
//TODO: instal satelite creator kit solutions (they do install togther with the main kit via appsource): https://learn.microsoft.com/en-us/power-platform/guidance/creator-kit/setup#step-2-install-the-reference-solutions-optional
resource "powerplatform_environment_application_package_install" "creator_kit_app_install" {
  count          = var.environment_parameters.install_creator_kit ? 1 : 0
  environment_id = powerplatform_environment.coe-kit-prod.id
  unique_name    = one(data.powerplatform_tenant_application_packages.creator_kit_app.applications).unique_name
}

//create coe-kit-prod environment
resource "powerplatform_environment" "coe-kit-prod" {
  location         = var.environment_parameters.env_location
  display_name     = var.environment_parameters.env_name
  environment_type = "Sandbox"
  dataverse = {
    language_code     = 1033
    currency_code     = "USD"
    security_group_id = "00000000-0000-0000-0000-000000000000"
  }
}

//TODO: setup DLP policies and assing to environments
//https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup#validate-data-loss-prevention-dlp-policies

//TODO: setup connections using script and maybe test engine?
//https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components#create-connections


resource "powerplatform_solution" "solution" {
  environment_id = powerplatform_environment.coe-kit-prod.id
  solution_file  = module.helpers.center_of_excellence_core_components_solution_zip_path
  solution_name  = "CenterofExcellenceCoreComponents"
  settings_file  = module.helpers.center_of_excellence_core_components_settings_file_path
}