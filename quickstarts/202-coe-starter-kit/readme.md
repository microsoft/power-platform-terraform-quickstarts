# Usage

1. `terraform init`
1. `terraform plan --var-file=prod.tfvars`
1. `terraform apply --var-file=prod.tfvars`
1. `terraform destroy --var-file=prod.tfvars`

## Prerequistes

1. The bash shell script [boostrap.sh](../../bootstrap/README.md) has been run

1. [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

1. Power Platform CLI (pac) has been downloaded and installed

1. Cross platform version of [PowerShell](https://learn.microsoft.com/powershell/scripting/install/installing-powershell) has been downloaded and installed

1. Azure Command CLI has been downloaded and installed

1. The logged in with api scope. For example to login with device code and specify the required tenant the following command could be used

> [!NOTE]
> Currently to create Power Platform connections you have to use service principal authentication.

```bash
az login --service-principal -u 01234567-1111-2222-3333-444455556666 -p abcdef1234354567890 --tenant 01234567-1111-2222-3333-444455556666
```

### Linux

Required linux commands as part of GitHUb DevContainer. For example

- (Debian/Ubuntu): Run `sudo apt-get install jq`
- [Install the Azure CLI on Linux](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux)

## Login

Assumes that environment as been logged in with api scope. For example to login with device code and specify the required tenant the following command could be used

```bash
az login --service-principal -u 01234567-1111-2222-3333-444455556666 -p abcdef1234354567890 --tenant 01234567-1111-2222-3333-444455556666
```

Follow github provider documentation for [authentication options](https://registry.terraform.io/providers/integrations/github/latest/docs#authentication)

## Example coe_toolkit.tfvars file

```hcl
release_parameters = {
  //if set to 'true' then the newest release will be dowloaded from github and used, the release tag parameter should be then empty
  coe_starter_kit_get_latest_release   = false,
  coe_starter_kit_specific_release_tag = "CoEStarterKit-September2024",

  //if set to 'true' then the newest release will be dowloaded from github and used, the release tag parameter should be then empty
  creator_kit_get_latest_release       = false,
  creator_kit_specific_release_tag     = "CreatorKit-May2024",
}

environment_parameters = {
  should_create_dlp_policy = true
  env_name     = "coe-kit-prod",
  env_location = "europe",
  env_type = "Sandbox"
}

connections_parameters = {
  should_create_connections = true,
  //we have two modes for creating connections: "terraform" and "test_engine"
  //if terraform is selected, the connection will be created using loginc in terraform_connections.tf 
  //if test_engine is selected, the connection will be created using test_engine_connections.tf. It will use the generated test engine connections.json file
  connection_create_mode = "terraform", //test_engine | terraform
  //if you want to see connections in makers portal, you have to share them with a user/group
  //if left empty, no connection will be shared
  //this is used only when connection_create_mode is "terraform"
  connection_share_with_object_id = "00000000-0000-0000-0000-000000000000",
  //share permission according to resource configuration: https://microsoft.github.io/terraform-provider-power-platform/resources/connection_share/
  //CanView", "CanViewWithShare", "CanEdit"
  //this is used only when connection_create_mode is "terraform"
  connection_share_permissions = "CanEdit"
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
  admin_audit_logs_client_secret                              = "", //client secret
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

## Using terraform for matrix testing

Lets assume we need to test following CoE installations in the follwing installation order:

| Step Name | Creator Kit Release | Coe Core Release |
| -------------| ------------- | ------------- |
| step-one.tfvars |CreatorKit-April2023 | CoEStarterKit-May2024 |
| step-two.tfvars |CreatorKit-July2023 | CoEStarterKit-June2024 |
| step-three.tfvars |CreatorKit-May2024 | CoEStarterKit-July2024 |

In order to validate, that the releases mentioned in the above table will upgrade without issues, we can run them using terraform in the following order:

```hcl
terraform init
terraform apply --var-file=step-one.tfvars
terraform apply --var-file=step-two.tfvars
terraform apply --var-file=step-three.tfvars
terraform destroy --var-file=step-three.tfvars
```

### TFVARS files configuraion

`step-one.tfvars`

```hcl
release_parameters = {
  coe_starter_kit_get_latest_release   = false,
  coe_starter_kit_specific_release_tag = "CoEStarterKit-May2024",
  creator_kit_get_latest_release   = false,
  creator_kit_specific_release_tag = "CreatorKit-April2023",
}

#rest of the tfvarfile remove for brevity
```

`step-two.tfvars`

```hcl
release_parameters = {
  coe_starter_kit_get_latest_release   = false,
  coe_starter_kit_specific_release_tag = "CoEStarterKit-June2024",
  creator_kit_get_latest_release   = false,
  creator_kit_specific_release_tag = "CreatorKit-July2023",
}

#rest of the tfvarfile remove for brevity
```

`step-three.tfvars`

```hcl
release_parameters = {
  coe_starter_kit_get_latest_release   = false,
  coe_starter_kit_specific_release_tag = "CoEStarterKit-July2024",
  creator_kit_get_latest_release   = false,
  creator_kit_specific_release_tag = "CreatorKit-May2024",
}

#rest of the tfvarfile remove for brevity
```
