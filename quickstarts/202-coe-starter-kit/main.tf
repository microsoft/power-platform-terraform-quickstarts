terraform {
  required_providers {
    powerplatform = {
      source  = "microsoft/power-platform"
      version = "2.7.0-preview"
    }
    github = {
      source = "integrations/github"
    }
  }
}


provider "powerplatform" {
  alias = "pp"
  use_cli = true
}

provider "github" {
  alias = "gh"
}

module "creator_kit" {
  source = "./creator_kit"
  providers = {
    github.gh = github.gh
  }
  parameters = {
    release = {
      creator_kit_get_latest_release   = var.release_parameters.creator_kit_get_latest_release,
      creator_kit_specific_release_tag = var.release_parameters.creator_kit_specific_release_tag,
    }
  }
}

module "coe_starter_kit" {
  source = "./coe_starter_kit"
  providers = {
    powerplatform.pp = powerplatform.pp
    github.gh = github.gh
  }
  parameters = {
    release = {
      coe_starter_kit_get_latest_release   = var.release_parameters.coe_starter_kit_get_latest_release,
      coe_starter_kit_specific_release_tag = var.release_parameters.coe_starter_kit_specific_release_tag,
    }
    env = {
      env_id = powerplatform_environment.coe_kit_env.id
      env_url = powerplatform_environment.coe_kit_env.dataverse.url
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
      admin_user_photos_forbidden_by_policy = var.core_components_parameters.admin_user_photos_forbidden_by_policy,
      coe_environment_request_admin_app_url = var.core_components_parameters.coe_environment_request_admin_app_url,
    }
  }
}

# //create coe-kit environment
resource "powerplatform_environment" "coe_kit_env" {
  provider = powerplatform.pp
  location         = var.environment_parameters.env_location
  display_name     = var.environment_parameters.env_name
  environment_type = "Sandbox"
  dataverse = {
    language_code     = 1033
    currency_code     = "USD"
    security_group_id = "00000000-0000-0000-0000-000000000000"
  }
}

//install creator-kit-core solution
# resource "powerplatform_solution" "creator_kit_solution_install" {
#   environment_id = powerplatform_environment.coe_kit_env.id
#   solution_file  = module.creator_kit.creator_kit_core_solution_zip_path
#   solution_name  = "CreatorKitCore"
# }

# //install coe-core-components solution
# resource "powerplatform_solution" "coe_core_solution_install" {
#   environment_id = powerplatform_environment.coe_kit_env.id
#   solution_file  = module.coe_starter_kit.center_of_excellence_core_components_solution_zip_path
#   solution_name  = "CenterofExcellenceCoreComponents"
#   settings_file  = module.coe_starter_kit.center_of_excellence_core_components_settings_file_path

#   depends_on = [powerplatform_solution.creator_kit_solution_install]
# }



//TODO: setup DLP policies and assing to environments
//https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup#validate-data-loss-prevention-dlp-policies

//TODO: setup connections using script and maybe test engine?
//https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components#create-connections



