variable "release_parameters" {
  description = "values for the github release parameters"
    type = object({
      coe_starter_kit_get_latest_release   = bool,
      coe_starter_kit_specific_release_tag = string,
      creator_kit_get_latest_release   = bool,
      creator_kit_specific_release_tag = string,
    })
}

variable "environment_parameters" {
    description = "values for the dataverse environment"
    type = object({
        env_name = string,
        env_location = string,
    })
}

variable "connections_parameters" {
    description = "values for the CenterofExcellence solution connections"
    type = object({
        should_create_connections = bool,
        connection_share_with_object_id = string,
        connection_share_permissions = string,
    })
}

variable core_components_parameters {
    description = "values for the CenterofExcellenceCoreComponents solution"
    type = object({
        admin_admine_mail_preferred_language = string,
        admin_admin_mail =   string,
        admin_app_connections_dataflow_id = string,
        admin_app_dataflow_id = string,
        admin_approval_admin = string,
        admin_app_usage_dataflow_id = string,
        admin_audit_logs_audience = string,
        admin_audit_logs_authority = string,
        admin_audit_logs_client_azure_secret = string,
        admin_audit_logs_client_id = string,
        admin_audit_logs_client_secret = string,
        admin_capacity_alert_percentage = string,
        admin_coe_system_user_id = string,
        admin_command_center_application_client_id = string,
        admin_command_center_client_azure_secret = string,
        admin_command_center_client_secret = string,
        admin_community_url = string,
        admin_company_name = string,
        admin_compliance_apps_number_days_since_published = string,
        admin_compliance_apps_number_groups_shared = string,
        admin_compliance_apps_number_launches_last_30_days = string,
        admin_compliance_apps_number_users_shared = string,
        admin_compliance_chatbots_number_launches = string,
        admin_delay_inventory = string,
        admin_delay_object_inventory = string,
        admin_delete_from_coe = string,
        admin_developer_compliance_center_url = string,
        admin_disabled_users_are_orphaned = string,
        admin_email_body_start = string,
        admin_email_body_stop = string,
        admin_email_header_style = string,
        admin_environment_dataflow_id = string,
        admin_env_request_auto_approve_certain_groups = string,
        admin_env_request_enable_cost_tracking = string,
        admin_flow_connections_dataflow_id = string,
        admin_flow_dataflow_id = string,
        admin_flow_usage_dataflow_id = string,
        admin_full_inventory = string,
        admin_graph_url_environment_variable = string,
        admin_host_domains = string,
        admin_inventory_and_telemetry_in_azure_data_storage_account = string,
        admin_inventory_filter_days_to_look_back = string,
        admin_is_full_tenant_inventory = string,
        admin_maker_dataflow_id = string,
        admin_model_app_dataflow_id = string,
        admin_power_app_environment_variable = string,
        admin_power_app_player_environment_variable = string,
        admin_power_automate_environment_variable = string,
        admin_power_platform_make_security_group = string,
        admin_power_platform_user_group_id = string,
        admin_production_environment = string,
        admin_sync_flow_errors_delete_after_x_days = string,
        admin_user_photos_forbidden_by_policy = string,
        coe_environment_request_admin_app_url = string,
    })
}
