terraform {
  required_providers {
    powerplatform = {
      source  = "microsoft/power-platform"
      version = "2.4.1-preview"
    }
  }
}

provider "powerplatform" {
  use_cli = true
}

module "helpers" {
  source = "./helpers"
  parameters = {
    env = {
      env_id = powerplatform_environment.coe-kit-prod.id
    }
    core = {
      admin_admine_mail_preferred_language                        = var.core_components_parameters.admin_admine_mail_preferred_language,
      admin_admin_mail                                            = var.core_components_parameters.admin_admin_mail,
      admin_app_connections_dataflow_id                           = var.core_components_parameters.admin_app_connections_dataflow_id,
      admin_app_dataflow_id                                       = var.core_components_parameters.admin_app_dataflow_id,
      admin_approval_admin                                        = var.core_components_parameters.admin_approval_admin,
      admin_app_usage_dataflow_id                                 = var.core_components_parameters.admin_app_usage_dataflow_id,
      admin_audit_logs_audience                                   = var.core_components_parameters.admin_audit_logs_audience,
      admin_audit_logs_authority                                  = var.core_components_parameters.admin_audit_logs_authority,
      admin_audit_logs_client_azure_secret                        = var.core_components_parameters.admin_audit_logs_client_azure_secret,
      admin_audit_logs_client_id                                  = var.core_components_parameters.admin_audit_logs_client_id,
      admin_audit_logs_client_secret                              = var.core_components_parameters.admin_audit_logs_client_secret,
      admin_capacity_alert_percentage                             = var.core_components_parameters.admin_capacity_alert_percentage,
      admin_coe_system_user_id                                    = var.core_components_parameters.admin_coe_system_user_id,
      admin_command_center_application_client_id                  = var.core_components_parameters.admin_command_center_application_client_id,
      admin_command_center_client_azure_secret                    = var.core_components_parameters.admin_command_center_client_azure_secret,
      admin_command_center_client_secret                          = var.core_components_parameters.admin_command_center_client_secret,
      admin_community_url                                         = var.core_components_parameters.admin_community_url,
      admin_company_name                                          = var.core_components_parameters.admin_company_name,
      admin_compliance_apps_number_days_since_published           = var.core_components_parameters.admin_compliance_apps_number_days_since_published,
      admin_compliance_apps_number_groups_shared                  = var.core_components_parameters.admin_compliance_apps_number_groups_shared,
      admin_compliance_apps_number_launches_last_30_days          = var.core_components_parameters.admin_compliance_apps_number_launches_last_30_days,
      admin_compliance_apps_number_users_shared                   = var.core_components_parameters.admin_compliance_apps_number_users_shared,
      admin_compliance_chatbots_number_launches                   = var.core_components_parameters.admin_compliance_chatbots_number_launches,
      admin_delay_inventory                                       = var.core_components_parameters.admin_delay_inventory,
      admin_delay_object_inventory                                = var.core_components_parameters.admin_delay_object_inventory,
      admin_delete_from_coe                                       = var.core_components_parameters.admin_delete_from_coe,
      admin_developer_compliance_center_url                       = var.core_components_parameters.admin_developer_compliance_center_url,
      admin_disabled_users_are_orphaned                           = var.core_components_parameters.admin_disabled_users_are_orphaned,
      admin_email_body_start                                      = var.core_components_parameters.admin_email_body_start,
      admin_email_body_stop                                       = var.core_components_parameters.admin_email_body_stop,
      admin_email_header_style                                    = var.core_components_parameters.admin_email_header_style,
      admin_environment_dataflow_id                               = var.core_components_parameters.admin_environment_dataflow_id,
      admin_env_request_auto_approve_certain_groups               = var.core_components_parameters.admin_env_request_auto_approve_certain_groups,
      admin_env_request_enable_cost_tracking                      = var.core_components_parameters.admin_env_request_enable_cost_tracking,
      admin_flow_connections_dataflow_id                          = var.core_components_parameters.admin_flow_connections_dataflow_id,
      admin_flow_dataflow_id                                      = var.core_components_parameters.admin_flow_dataflow_id,
      admin_flow_usage_dataflow_id                                = var.core_components_parameters.admin_flow_usage_dataflow_id,
      admin_full_inventory                                        = var.core_components_parameters.admin_full_inventory,
      admin_graph_url_environment_variable                        = var.core_components_parameters.admin_graph_url_environment_variable,
      admin_host_domains                                          = var.core_components_parameters.admin_host_domains,
      admin_inventory_and_telemetry_in_azure_data_storage_account = var.core_components_parameters.admin_inventory_and_telemetry_in_azure_data_storage_account,
      admin_inventory_filter_days_to_look_back                    = var.core_components_parameters.admin_inventory_filter_days_to_look_back,
      admin_is_full_tenant_inventory                              = var.core_components_parameters.admin_is_full_tenant_inventory,
      admin_maker_dataflow_id                                     = var.core_components_parameters.admin_maker_dataflow_id,
      admin_model_app_dataflow_id                                 = var.core_components_parameters.admin_model_app_dataflow_id,
      admin_power_app_environment_variable                        = var.core_components_parameters.admin_power_app_environment_variable,
      admin_power_app_player_environment_variable                 = var.core_components_parameters.admin_power_app_player_environment_variable,
      admin_power_automate_environment_variable                   = var.core_components_parameters.admin_power_automate_environment_variable,
      admin_power_platform_make_security_group                    = var.core_components_parameters.admin_power_platform_make_security_group,
      admin_power_platform_user_group_id                          = var.core_components_parameters.admin_power_platform_user_group_id,
      admin_production_environment                                = var.core_components_parameters.admin_production_environment,
      admin_sync_flow_errors_delete_after_x_days                  = var.core_components_parameters.admin_sync_flow_errors_delete_after_x_days,
      admin_tenant_id                                             = var.core_components_parameters.admin_tenant_id,
      //admin_tenant_id                                             = jsondecode(data.powerplatform_rest_query.org_details.output.body).Detail.TenantId
      admin_user_photos_forbidden_by_policy                       = var.core_components_parameters.admin_user_photos_forbidden_by_policy,
      coe_environment_request_admin_app_url                       = var.core_components_parameters.coe_environment_request_admin_app_url,
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

#TODO: uncomment with next provider' release to get tenantid param
# data "powerplatform_rest_query" "org_details" {
#   scope                = "${powerplatform_environment.env.dataverse.url}/.default"
#   url                  = "${powerplatform_environment.env.dataverse.url}/api/data/v9.2/RetrieveCurrentOrganization(AccessType=@p1)?@p1=Microsoft.Dynamics.CRM.EndpointAccessType'Default'"
#   method               = "GET"
#   expected_http_status = [200]
# }



//TODO: setup DLP policies and assing to environments
//https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup#validate-data-loss-prevention-dlp-policies

//TODO: setup connections using script and maybe test engine?
//https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components#create-connections



resource "powerplatform_solution" "solution" {
  environment_id = powerplatform_environment.coe-kit-prod.id
  solution_file  = module.helpers.center_of_excellence_core_components_solution_zip_path
  solution_name  = "CenterofExcellenceCoreComponents"
  settings_file  = module.helpers.center_of_excellence_core_components_settings_file_path

  depends_on = [powerplatform_environment_application_package_install.creator_kit_app_install]
}
