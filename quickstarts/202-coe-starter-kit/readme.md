# Usage

1. `terraform init`
1. `terraform plan --var-file=prod.tfvars`
1. `terraform apply --var-file=prod.tfvars`

## Example tfvars file

```hcl
environment_parameters = {
  env_name     = "coe-kit-prod",
  env_location = "europe",
}

core_components_parameters = {
  admin_admine_mail_preferred_language                        = "en-US",
  admin_admin_mail                                            = "admin@contoso.com",
  admin_app_connections_dataflow_id                           = "", //empty for import //what is that?
  admin_app_dataflow_id                                       = "", //empty for import //what is that?
  admin_approval_admin                                        = "admin@contoso.com",
  admin_app_usage_dataflow_id                                 = "", //empty for import //what is that?
  admin_audit_logs_audience                                   = "", //what is that?
  admin_audit_logs_authority                                  = ""  //what is that?
  admin_audit_logs_client_azure_secret                        = "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RESOURCE_GROUP_NAME>/providers/Microsoft.KeyVault/vaults/<KV_NAME>/secrets/<SECRET_NAME>",
  admin_audit_logs_client_id                                  = "", //Client ID of the Office 365 Management API Azure AD service principal // do we have to create that?
  admin_audit_logs_client_secret                              = "",
  admin_capacity_alert_percentage                             = "0.8",
  admin_coe_system_user_id                                    = "", //which user is that? we can query this on import
  admin_command_center_application_client_id                  = "", //app registered to fetch M365 Service Messages //where is that?
  admin_command_center_client_azure_secret                    = "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RESOURCE_GROUP_NAME>/providers/Microsoft.KeyVault/vaults/<KV_NAME>/secrets/<SECRET_NAME>",
  admin_command_center_client_secret                          = "",
  admin_community_url                                         = "http://contoso.sharepoint.com/sites/COE",
  admin_company_name                                          = "Contoso",
  admin_compliance_apps_number_days_since_published           = "60", //for this that have default value, do we want to set the same value here for readability?
  admin_compliance_apps_number_groups_shared                  = "1",
  admin_compliance_apps_number_launches_last_30_days          = "30",
  admin_compliance_apps_number_users_shared                   = "20",
  admin_compliance_chatbots_number_launches                   = "50",
  admin_delay_inventory                                       = "yes",
  admin_delay_object_inventory                                = "no",
  admin_delete_from_coe                                       = "yes",
  admin_developer_compliance_center_url                       = "", //where is that? URL to Developer Compliance Center Canvas App.
  admin_disabled_users_are_orphaned                           = "no",
  admin_email_body_start                                      = "<body><div id='content'><table id='form'><tr><td><img id='logo' src='https://upload.wikimedia.org/wikipedia/commons/thumb/9/96/Microsoft_logo_%282012%29.svg/1280px-Microsoft_logo_%282012%29.svg.png' width='300'></td>             </tr>             <tr>                 <td>                     <p id='header'>Power Platform</p>                 </td>             </tr>             <tr id='ribbon'>                 <td>                     <tr>                       <td></td></tr><tr id='message'><td>",
  admin_email_body_stop                                       = "</td></tr></table></div></body>"
  admin_email_header_style                                    = "<head><style>body{background-color:#efefef;font-family:SegoeUI;text-align:center;}#content{border:1pxsolid#742774;background-color:#ffffff;width:650px;margin-bottom:50px;display:inline-block;}#logo{margin-left:52px;margin-top:40px;width:60px;height:12px;}#header{font-size:24px;margin-left:50px;margin-top:20px;margin-bottom:20px;}#ribbon{background-color:#742774;}#ribbonContent{font-size:20px;padding-left:30px;padding-top:10px;padding-bottom:20px;color:white;width:100%;padding-right:10px;}#message>td{font-size:14px;padding-left:60px;padding-right:60px;padding-top:20px;padding-bottom:40px;}#footer>td{font-size:12px;background-color:#cfcfcf;height:40px;padding-top:15px;padding-left:40px;padding-bottom:20px;}#form{width:100%;border-collapse:collapse;}#app{width:60%;font-size:12px;}.label{color:#5f5f5f}table{border-collapse:collapse;width:100%;}th,td{padding:8px;text-align:left;border-bottom:1pxsolid#ddd;}</style></head>",
  admin_environment_dataflow_id                               = "", //what is that? Dataflow ID of the CoE BYODL Environments dataflow.
  admin_env_request_auto_approve_certain_groups               = "no",
  admin_env_request_enable_cost_tracking                      = "no",
  admin_flow_connections_dataflow_id                          = "", //what is that? Flow Connections Dataflow ID.
  admin_flow_dataflow_id                                      = "", //what is that? Dataflow ID of the CoE BYODL Flows dataflow.
  admin_flow_usage_dataflow_id                                = "", //what is that? Flow Usage Dataflow ID."
  admin_full_inventory                                        = "no",
  admin_graph_url_environment_variable                        = "https://graph.microsoft.com/",
  admin_host_domains                                          = "contoso.onmicrosoft.com",
  admin_inventory_and_telemetry_in_azure_data_storage_account = "no",
  admin_inventory_filter_days_to_look_back                    = "7",
  admin_is_full_tenant_inventory                              = "yes",
  admin_maker_dataflow_id                                     = "", //what is that? Dataflow ID of the CoE BYODL Makers dataflow.
  admin_model_app_dataflow_id                                 = "", //what is that? Dataflow ID of the dataflow that processes model driven apps. Used for BYODL only.
  admin_power_app_environment_variable                        = "https://make.powerapps.com/",
  admin_power_app_player_environment_variable                 = "https://apps.powerapps.com/",
  admin_power_automate_environment_variable                   = "https://flow.microsoft.com/manage/environments/",
  admin_power_platform_make_security_group                    = "",
  admin_power_platform_user_group_id                          = "",
  admin_production_environment                                = "yes", //that should be terraform var parameter?
  admin_sync_flow_errors_delete_after_x_days                  = "7",
  admin_tenant_id                                             = "", //TODO
  admin_user_photos_forbidden_by_policy                       = "no",
  coe_environment_request_admin_app_url                       = "", //where is that? URL to the CoE Environment Request Admin Canvas App.
}
```
