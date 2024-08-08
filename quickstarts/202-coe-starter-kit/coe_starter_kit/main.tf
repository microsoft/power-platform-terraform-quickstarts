terraform {
  required_providers {
    powerplatform = {
      source  = "microsoft/power-platform"
      configuration_aliases = [ powerplatform.pp ]
    }
    github = {
      source = "integrations/github"
      configuration_aliases = [ github.gh ]
    }
  }
}

#get tenantid param
data "powerplatform_rest_query" "org_details" {
  provider = powerplatform.pp
  scope                = "${var.parameters.env.env_url}/.default"
  url                  = "${var.parameters.env.env_url}/api/data/v9.2/RetrieveCurrentOrganization(AccessType=@p1)?@p1=Microsoft.Dynamics.CRM.EndpointAccessType'Default'"
  method               = "GET"
  expected_http_status = [200]
}

locals {
  coe_start_kit_asset_url = [for i in data.github_release.coe_starter_kit_release.assets : i.browser_download_url if i.name == "CoEStarterKit.zip"]
}

data "github_release" "coe_starter_kit_release" {
    repository  = "coe-starter-kit"
    owner       = "microsoft"
    retrieve_by = var.parameters.release.coe_starter_kit_get_latest_release == true ? "latest" : "tag"
    release_tag = var.parameters.release.coe_starter_kit_specific_release_tag
}

resource "null_resource" "coe_starter_kit_download_solutions_zip" {
  triggers = {
    always_run = local.coe_start_kit_asset_url[0]
  }

  provisioner "local-exec" {
    command = "Invoke-WebRequest -Uri $env:COE_ASSET_URL -OutFile \"$env:MODULE_PATH/coe-starter-kit.zip\""
    when    = create
    interpreter = ["pwsh","-Command"]
    environment = {
      MODULE_PATH = path.module
      COE_ASSET_URL = local.coe_start_kit_asset_url[0]
    }
  }

  provisioner "local-exec" {
    command = "Remove-Item -Path \"$env:MODULE_PATH/coe-starter-kit.zip\" -Force"
    when    = destroy
    interpreter = ["pwsh","-Command"]
    environment = {
      MODULE_PATH = path.module
    }
  }

  depends_on = [ data.github_release.coe_starter_kit_release ]
}

//extract the solutions
resource "null_resource" "coe_starter_kit_extract_solutions_zip" {
  triggers = {
    always_run = local.coe_start_kit_asset_url[0]
  }

  provisioner "local-exec" {
    command = "Expand-Archive -Path \"$env:MODULE_PATH/coe-starter-kit.zip\" -DestinationPath \"$env:MODULE_PATH/coe-starter-kit-extracted\" -Force"
    when    = create
    interpreter = ["pwsh","-Command"]
    environment = {
      MODULE_PATH = path.module
    }
  }

  provisioner "local-exec" {
    command = "Remove-Item -Path \"$env:MODULE_PATH/coe-starter-kit-extracted\" -Recurse -Force"
    when    = destroy
    interpreter = ["pwsh","-Command"]
    environment = {
      MODULE_PATH = path.module
    }
  }

  depends_on = [null_resource.coe_starter_kit_download_solutions_zip]
}

//because CenterofExcellenceCoreComponents_X_X.managed is in a specific version, we have to rename it to a fixed name
resource "null_resource" "rename_center_of_excellence_core_components_solution" {
  triggers = {
    always_run = local.coe_start_kit_asset_url[0]
  }

  provisioner "local-exec" {
    command = "Set-Location -Path \"$env:MODULE_PATH/coe-starter-kit-extracted\"; Get-Childitem \"CenterofExcellenceCoreComponents_*.zip\" |  ForEach-Object {  Move-Item $_ $_.Name.Replace($_.Name, \"CenterofExcellenceCoreComponents.zip\") -Force }"
    when    = create
    interpreter = ["pwsh","-Command"]
    environment = {
      MODULE_PATH = path.module
    }
  }
  depends_on = [null_resource.coe_starter_kit_extract_solutions_zip]
}


//TODO add comment expalining where that came from and how to update it if you need new connections referenced going into your new released solution
//Those connections are hardcoded and represent the connections that are created in the solution by extracting them from solution.zip file using the following command:
//pac solution create-settings --solution-zip .\CenterofExcellenceCoreComponents_X_XX_X_managed.zip --settings-file out.json
//
//If you need new connections to be referenced in the new solution, you need to update this list by running the above command with the new solution.zip file and updating the list below
//Field description:
//name: the name of the connector 
//logicalName: the name of the connection reference in the solution
//display_name: the display name of the connection (is used only if you create connections using powerplatform_connection resource, not test engine)
//connection_parameters: the auth connection parameters of the connection (is used only if you create connections using powerplatform_connection resource, not test engine)
//connection_parameters_set: the auth connection parameters set of the connection (is used only if you create connections using powerplatform_connection resource, not test engine)
locals {
  office365_users_connections = [
     {
      name = "shared_office365users"
      logicalName = "admin_CoECoreO365Users"
      display_name = "CoE Core - O365 Users Connection"
      connection_parameters = jsonencode({})
      connection_parameters_set = null
    },
    {
      name = "shared_office365users"
      logicalName = "admin_CoECoreOffice365Users"
      display_name = "CoE Core - Office 365 Users Connection"
      connection_parameters = jsonencode({})
      connection_parameters_set = null
    },
  ]
  powerplatform_admin_connections = [
    {
      name ="shared_powerplatformforadmins"
      logicalName = "admin_CoECorePowerPlatformforAdmins"
      display_name = "CoE Core - Power Platform for Admins (Env Request) Connection"
      connection_parameters = jsonencode({})
      connection_parameters_set = null
    },
    {
      name ="shared_powerplatformforadmins"
      logicalName = "admin_CoECorePowerPlatformforAdminsEnvRequest"
      display_name = "CoE Core - Power Apps Admin Connection"
      connection_parameters = jsonencode({})
      connection_parameters_set = null
    },
  ]
   powerapps_admin_connections = [
    {
      name ="shared_powerappsforadmins"
      logicalName = "admin_CoECorePowerAppsAdmin"
      display_name = "CoE Core - Power Apps for Admins Connection"
      connection_parameters = jsonencode({})
      connection_parameters_set = null
    },
    {
      name ="shared_powerappsforadmins"
      logicalName = "admin_CoECorePowerAppsAdmin2"
      display_name = "CoE Core - Power Apps for Admins 2 Connection"
      connection_parameters = jsonencode({})
      connection_parameters_set = null
    },
  ]
  dataverse_connections = [
    {
      name = "shared_commondataserviceforapps"
      logicalName = "admin_CoECoreDataverseEnvRequest"
      display_name = "CoE Core - Dataverse (Env Request) Connection"
      connection_parameters = jsonencode({"token:grantType":"code"})
      connection_parameters_set = null
    },
    {
      name = "shared_commondataserviceforapps"
      logicalName = "admin_CoECoreDataverseForApps"
      display_name = "CoE Core - Dataverse Connection"
      connection_parameters = jsonencode({"token:grantType":"code"})
      connection_parameters_set = null
    },
    {
      name = "shared_commondataserviceforapps"
      logicalName = "admin_CoECoreDataverse"
      display_name = "CoE Core - Dataverse For Apps Connection"
      connection_parameters = jsonencode({"token:grantType":"code"})
      connection_parameters_set = null
    },
    {
      name = "shared_commondataserviceforapps"
      logicalName = "admin_CoECoreDataverse2"
      display_name = "CoE Core - Dataverse2 Connection"
      connection_parameters = jsonencode({"token:grantType":"code"})
      connection_parameters_set = null
    },
    {
      name = "shared_commondataserviceforapps"
      logicalName = "admin_sharedcommondataserviceforapps_98924"
      display_name = "CoE Core - Dataverse for Environment Request Connection"
      connection_parameters = jsonencode({"token:grantType":"code"})
      connection_parameters_set = null
    },
    {
      name = "shared_commondataserviceforapps"
      logicalName = "admin_CoEBYODLDataverse"
      display_name = "CoE BYODL - Dataverse Connection"
      connection_parameters = jsonencode({"token:grantType":"code"})
      connection_parameters_set = null
    },
  ]
  single_connections = [
    {
      name = "shared_office365"
      logicalName = "admin_CoECoreO365Outlook"
      display_name = "CoE Core - O365 Outlook Connection"
      connection_parameters = jsonencode({})
      connection_parameters_set = null
    },
    {
      name = "shared_powerappsforappmakers"
      logicalName = "admin_CoECorePowerAppsMakers"
      display_name = "CoE Core - PowerApps for App Makers Connection"
      connection_parameters = jsonencode({})
      connection_parameters_set = null
    },
    {
      name = "shared_teams"
      logicalName = "admin_CoECoreTeams"
      display_name = "CoE Core - Teams Connection"
      connection_parameters = jsonencode({})
      connection_parameters_set = null
    },
    {
      name = "shared_flowmanagement"
      logicalName = "admin_CoECorePowerAutomateManagement"
      display_name = "CoE Core - Power Automate Management Connection"
      connection_parameters = null
      connection_parameters_set = jsonencode({"name":"firstParty","values":{"token":{"value":"https://global.consent.azure-apim.net/redirect/flowmanagement"}}})
    },
    {
      name = "shared_webcontents"
      logicalName = "admin_CoECoreHTTPWithAzureAD"
      display_name = "CoE Core - HTTP With Azure AD Connection"
      connection_parameters = jsonencode({"token:ResourceUri":"https://graph.microsoft.com","baseResourceUrl":"https://graph.microsoft.com","privacySetting":"None"})
      connection_parameters_set = null
    },
    {
      name = "shared_dataflows"
      logicalName = "admin_CoEBYODLPowerQuery"
      display_name = "CoE BYODL - Power Query Connection"
      connection_parameters = jsonencode({})
      connection_parameters_set = null
    },
    {
      name = "shared_office365groups"
      logicalName = "admin_CoECoreO365Groups"
      display_name = "CoE Core - O365 Groups Connection"
      connection_parameters = jsonencode({})
      connection_parameters_set = null
    },
    {
      name = "shared_microsoftflowforadmins"
      logicalName = "admin_CoECorePowerAutomateAdmin"
      display_name = "CoE Core - Power Automate Admin Connection"
      connection_parameters = jsonencode({})
      connection_parameters_set = null
    },
  ]

  all_connections = concat(local.office365_users_connections,local.powerapps_admin_connections, local.powerplatform_admin_connections, local.dataverse_connections, local.single_connections)
}


//this file is generated using:
//pac solution create-settings --solution-zip .\CenterofExcellenceCoreComponents_4_32_2_managed.zip --settings-file out.json
resource "local_file" "solution_settings_file" {
  filename = "${path.module}/CenterofExcellenceCoreComponents_solution_settings.json"
  content  = <<EOF
{
  "EnvironmentVariables": [
    {
      "SchemaName": "admin_AdmineMailPreferredLanguage",
      "Value": "${var.parameters.core.admin_admine_mail_preferred_language}",
      "DefaultValue": "en-US",
      "Name": {
        "Default": "Admin eMail Preferred Language",
        "ByLcid": {
          "1033": "Admin eMail Preferred Language"
        }
      },
      "Description": {
        "Default": "Inventory - The preferred language for the emails sent to the admin email alias, which is specified in theAdmin eMail environment variable. Default is en-US",
        "ByLcid": {
          "1033": "Inventory - The preferred language for the emails sent to the admin email alias, which is specified in theAdmin eMail environment variable. Default is en-US"
        }
      }
    },
    {
      "SchemaName": "admin_AdminMail",
      "Value": "${var.parameters.core.admin_admin_mail}",
      "Name": {
        "Default": "Admin eMail",
        "ByLcid": {
          "1033": "Admin eMail"
        }
      },
      "Description": {
        "Default": "Inventory - CoE Admin eMail. Email address used in flows to send notifications to admins; this should be either your email address or a distribution list",
        "ByLcid": {
          "1033": "Inventory - CoE Admin eMail. Email address used in flows to send notifications to admins; this should be either your email address or a distribution list"
        }
      }
    },
    {
      "SchemaName": "admin_AppConnectionsDataflowID",
      "Value": "${var.parameters.core.admin_app_connections_dataflow_id}",
      "Name": {
        "Default": "App Connections Dataflow ID",
        "ByLcid": {
          "1033": "App Connections Dataflow ID"
        }
      },
      "Description": {
        "Default": "LEAVE EMPTY ON IMPORT. App Connections Dataflow ID.",
        "ByLcid": {
          "1033": "LEAVE EMPTY ON IMPORT. App Connections Dataflow ID."
        }
      }
    },
    {
      "SchemaName": "admin_AppDataflowID",
      "Value": "${var.parameters.core.admin_app_dataflow_id}",
      "Name": {
        "Default": "App Dataflow ID",
        "ByLcid": {
          "1033": "App Dataflow ID"
        }
      },
      "Description": {
        "Default": "LEAVE BLANK ON IMPORT. Dataflow ID of the CoE BYODL Apps dataflow.",
        "ByLcid": {
          "1033": "LEAVE BLANK ON IMPORT. Dataflow ID of the CoE BYODL Apps dataflow."
        }
      }
    },
    {
      "SchemaName": "admin_ApprovalAdmin",
      "Value": "${var.parameters.core.admin_approval_admin}",
      "Name": {
        "Default": "Individual Admin",
        "ByLcid": {
          "1033": "Individual Admin"
        }
      },
      "Description": {
        "Default": "Inventory - REQUIRED. An individual admin's email. Some actions (approvals / team chats) cannot accept a group/DL. So this env variable is for those instances in the kit. ",
        "ByLcid": {
          "1033": "Inventory - REQUIRED. An individual admin's email. Some actions (approvals / team chats) cannot accept a group/DL. So this env variable is for those instances in the kit. "
        }
      }
    },
    {
      "SchemaName": "admin_AppUsageDataflowID",
      "Value": "${var.parameters.core.admin_app_usage_dataflow_id}",
      "Name": {
        "Default": "App Usage Dataflow ID",
        "ByLcid": {
          "1033": "App Usage Dataflow ID"
        }
      },
      "Description": {
        "Default": "LEAVE EMPTY ON IMPORT. App Usage Dataflow ID.",
        "ByLcid": {
          "1033": "LEAVE EMPTY ON IMPORT. App Usage Dataflow ID."
        }
      }
    },
    {
      "SchemaName": "admin_AuditLogsAudience",
      "Value": "${var.parameters.core.admin_audit_logs_audience}",
      "Name": {
        "Default": "Audit Logs - Audience",
        "ByLcid": {
          "1033": "Audit Logs - Audience"
        }
      },
      "Description": {
        "Default": "AuditLogs - The audience for the HTTP connector. Set by Setup wizard based on tenant type",
        "ByLcid": {
          "1033": "AuditLogs - The audience for the HTTP connector. Set by Setup wizard based on tenant type"
        }
      }
    },
    {
      "SchemaName": "admin_AuditLogsAuthority",
      "Value": "${var.parameters.core.admin_audit_logs_authority}",
      "Name": {
        "Default": "Audit Logs - Authority",
        "ByLcid": {
          "1033": "Audit Logs - Authority"
        }
      },
      "Description": {
        "Default": "AuditLogs - The authority for the HTTP connector. Set by Setup wizard based on tenant type",
        "ByLcid": {
          "1033": "AuditLogs - The authority for the HTTP connector. Set by Setup wizard based on tenant type"
        }
      }
    },
    {
      "SchemaName": "admin_AuditLogsClientAzureSecret",
      "Value": "${var.parameters.core.admin_audit_logs_client_azure_secret}",
      "Name": {
        "Default": "Audit Logs - Client Azure Secret",
        "ByLcid": {
          "1033": "Audit Logs - Client Azure Secret"
        }
      },
      "Description": {
        "Default": "AuditLogs - Client secret of the Office 365 Management API Azure AD service principal stored in Azure KeyVault. Use only if you have stored your secret in Azure Key Vault.",
        "ByLcid": {
          "1033": "AuditLogs - Client secret of the Office 365 Management API Azure AD service principal stored in Azure KeyVault. Use only if you have stored your secret in Azure Key Vault."
        }
      }
    },
    {
      "SchemaName": "admin_AuditLogsClientID",
      "Value": "${var.parameters.core.admin_audit_logs_client_id}",
      "Name": {
        "Default": "Audit Logs - ClientID",
        "ByLcid": {
          "1033": "Audit Logs - ClientID"
        }
      },
      "Description": {
        "Default": "AuditLogs - Client ID of the Office 365 Management API Azure AD service principal",
        "ByLcid": {
          "1033": "AuditLogs - Client ID of the Office 365 Management API Azure AD service principal"
        }
      }
    },
    {
      "SchemaName": "admin_AuditLogsClientSecret",
      "Value": "${var.parameters.core.admin_audit_logs_client_secret}",
      "Name": {
        "Default": "Audit Logs - Client Secret",
        "ByLcid": {
          "1033": "Audit Logs - Client Secret"
        }
      },
      "Description": {
        "Default": "AuditLogs - Client secret of the Office 365 Management API Azure AD service principal",
        "ByLcid": {
          "1033": "AuditLogs - Client secret of the Office 365 Management API Azure AD service principal"
        }
      }
    },
    {
      "SchemaName": "admin_Capacityalertpercentage",
      "Value": "${var.parameters.core.admin_capacity_alert_percentage}",
      "DefaultValue": "0.8",
      "Name": {
        "Default": "Capacity alert percentage ",
        "ByLcid": {
          "1033": "Capacity alert percentage "
        }
      },
      "Description": {
        "Default": "Percentage amount of capacity used at which to alert. Deault is 0.8 (80%)",
        "ByLcid": {
          "1033": "Percentage amount of capacity used at which to alert. Deault is 0.8 (80%)"
        }
      }
    },
    {
      "SchemaName": "admin_CoESystemUserID",
      "Value": "${var.parameters.core.admin_coe_system_user_id}",
      "Name": {
        "Default": "CoE System User ID",
        "ByLcid": {
          "1033": "CoE System User ID"
        }
      },
      "Description": {
        "Default": "in the maker table we store a user for system with an id. Storing here so that it can be referenced without having to look it up all the time.",
        "ByLcid": {
          "1033": "in the maker table we store a user for system with an id. Storing here so that it can be referenced without having to look it up all the time."
        }
      }
    },
    {
      "SchemaName": "admin_CommandCenterApplicationClientID",
      "Value": "${var.parameters.core.admin_command_center_application_client_id}",
      "Name": {
        "Default": "Command Center - Application Client ID",
        "ByLcid": {
          "1033": "Command Center - Application Client ID"
        }
      },
      "Description": {
        "Default": "Inventory - LEAVE EMPTY ON IMPORT. Application Client ID for the app registered to fetch M365 Service Messages",
        "ByLcid": {
          "1033": "Inventory - LEAVE EMPTY ON IMPORT. Application Client ID for the app registered to fetch M365 Service Messages"
        }
      }
    },
    {
      "SchemaName": "admin_CommandCenterClientAzureSecret",
      "Value": "${var.parameters.core.admin_command_center_client_azure_secret}",
      "Name": {
        "Default": "Command Center - Client Azure Secret",
        "ByLcid": {
          "1033": "Command Center - Client Azure Secret"
        }
      },
      "Description": {
        "Default": "Inventory - LEAVE EMPTY ON IMPORT. Azure Key Vault ID of the Client Secret for the app registered to fetch M365 Service Messages. Use only if you have stored your secret in Azure Key Vault.",
        "ByLcid": {
          "1033": "Inventory - LEAVE EMPTY ON IMPORT. Azure Key Vault ID of the Client Secret for the app registered to fetch M365 Service Messages. Use only if you have stored your secret in Azure Key Vault."
        }
      }
    },
    {
      "SchemaName": "admin_CommandCenterClientSecret",
      "Value": "${var.parameters.core.admin_command_center_client_secret}",
      "Name": {
        "Default": "Command Center - Client Secret",
        "ByLcid": {
          "1033": "Command Center - Client Secret"
        }
      },
      "Description": {
        "Default": "Inventory - LEAVE EMPTY ON IMPORT. Text version of the Client Secret for the app registered to fetch M365 Service Messages",
        "ByLcid": {
          "1033": "Inventory - LEAVE EMPTY ON IMPORT. Text version of the Client Secret for the app registered to fetch M365 Service Messages"
        }
      }
    },
    {
      "SchemaName": "admin_CommunityURL",
      "Value": "${var.parameters.core.admin_community_url}",
      "Name": {
        "Default": "Community URL",
        "ByLcid": {
          "1033": "Community URL"
        }
      },
      "Description": {
        "Default": "Link to your internal Microsoft Power Platform community (for example, Yammer or Teams)",
        "ByLcid": {
          "1033": "Link to your internal Microsoft Power Platform community (for example, Yammer or Teams)"
        }
      }
    },
    {
      "SchemaName": "admin_CompanyName",
      "Value": "${var.parameters.core.admin_company_name}",
      "Name": {
        "Default": "CompanyName",
        "ByLcid": {
          "1033": "CompanyName"
        }
      },
      "Description": {
        "Default": "Inventory - The name of the company to be displayed in various apps, emails, and so forth.",
        "ByLcid": {
          "1033": "Inventory - The name of the company to be displayed in various apps, emails, and so forth."
        }
      }
    },
    {
      "SchemaName": "admin_ComplianceAppsNumberDaysSincePublished",
      "Value": "${var.parameters.core.admin_compliance_apps_number_days_since_published}",
      "DefaultValue": "60",
      "Name": {
        "Default": "Compliance – Apps – Number Days Since Published",
        "ByLcid": {
          "1033": "Compliance – Apps – Number Days Since Published"
        }
      },
      "Description": {
        "Default": "Compliance – If an app is broadly shared and was last published this many days ago or older, then they are asked to publish to stay compliant. Default 60",
        "ByLcid": {
          "1033": "Compliance – If an app is broadly shared and was last published this many days ago or older, then they are asked to publish to stay compliant. Default 60"
        }
      }
    },
    {
      "SchemaName": "admin_ComplianceAppsNumberGroupsShared",
      "Value": "${var.parameters.core.admin_compliance_apps_number_groups_shared}",
      "DefaultValue": "1",
      "Name": {
        "Default": "Compliance – Apps – Number Groups Shared",
        "ByLcid": {
          "1033": "Compliance – Apps – Number Groups Shared"
        }
      },
      "Description": {
        "Default": "Compliance – If the app is shared with this many or more groups, ask for business justification. Default 1",
        "ByLcid": {
          "1033": "Compliance – If the app is shared with this many or more groups, ask for business justification. Default 1"
        }
      }
    },
    {
      "SchemaName": "admin_ComplianceAppsNumberLaunchesLast30Days",
      "Value": "${var.parameters.core.admin_compliance_apps_number_launches_last_30_days}",
      "DefaultValue": "30",
      "Name": {
        "Default": "Compliance – Apps – Number Launches Last 30 Days",
        "ByLcid": {
          "1033": "Compliance – Apps – Number Launches Last 30 Days"
        }
      },
      "Description": {
        "Default": "Compliance – If the app was launched at least this many times in the last 30, ask for business justification. Default 30.",
        "ByLcid": {
          "1033": "Compliance – If the app was launched at least this many times in the last 30, ask for business justification. Default 30."
        }
      }
    },
    {
      "SchemaName": "admin_ComplianceAppsNumberUsersShared",
      "Value": "${var.parameters.core.admin_compliance_apps_number_users_shared}",
      "DefaultValue": "20",
      "Name": {
        "Default": "Compliance – Apps - Number Users Shared",
        "ByLcid": {
          "1033": "Compliance – Apps - Number Users Shared"
        }
      },
      "Description": {
        "Default": "Compliance – If the app is shared with this many or more users, ask for business justification. Default 20",
        "ByLcid": {
          "1033": "Compliance – If the app is shared with this many or more users, ask for business justification. Default 20"
        }
      }
    },
    {
      "SchemaName": "admin_ComplianceChatbotsNumberLaunches",
      "Value": "${var.parameters.core.admin_compliance_chatbots_number_launches}",
      "DefaultValue": "50",
      "Name": {
        "Default": "Compliance – Chatbots – Number Launches",
        "ByLcid": {
          "1033": "Compliance – Chatbots – Number Launches"
        }
      },
      "Description": {
        "Default": "Compliance – If the chatbot is launched this many or more times, ask for business justification. Default 50",
        "ByLcid": {
          "1033": "Compliance – If the chatbot is launched this many or more times, ask for business justification. Default 50"
        }
      }
    },
    {
      "SchemaName": "admin_CurrentEnvironment",
      "Value": "${var.parameters.env.env_id}",
      "Name": {
        "Default": "Current Environment",
        "ByLcid": {
          "1033": "Current Environment"
        }
      },
      "Description": {
        "Default": "Current Environment ID.",
        "ByLcid": {
          "1033": "Current Environment ID."
        }
      }
    },
    {
      "SchemaName": "admin_DelayInventory",
      "Value": "${var.parameters.core.admin_delay_inventory}",
      "DefaultValue": "yes",
      "Name": {
        "Default": "DelayInventory",
        "ByLcid": {
          "1033": "DelayInventory"
        }
      },
      "Description": {
        "Default": "Inventory - If Yes, will run a delay step to assist with the Dataverse health. Only turn to No for debugging. ",
        "ByLcid": {
          "1033": "Inventory - If Yes, will run a delay step to assist with the Dataverse health. Only turn to No for debugging. "
        }
      }
    },
    {
      "SchemaName": "admin_DelayObjectInventory",
      "Value": "${var.parameters.core.admin_delay_object_inventory}",
      "DefaultValue": "no",
      "Name": {
        "Default": "DelayObjectInventory",
        "ByLcid": {
          "1033": "DelayObjectInventory"
        }
      },
      "Description": {
        "Default": "Inventory - If Yes, will run a delay step to assist with the Dataverse throttling. Things like solutions, apps, flows, will have delays in the individual envt runs. Default No.",
        "ByLcid": {
          "1033": "Inventory - If Yes, will run a delay step to assist with the Dataverse throttling. Things like solutions, apps, flows, will have delays in the individual envt runs. Default No."
        }
      }
    },
    {
      "SchemaName": "admin_DeleteFromCoE",
      "Value": "${var.parameters.core.admin_delete_from_coe}",
      "DefaultValue": "yes",
      "Name": {
        "Default": "Also Delete From CoE",
        "ByLcid": {
          "1033": "Also Delete From CoE"
        }
      },
      "Description": {
        "Default": "Inventory - when we run \"Admin | Sync Template v2 (Check Deleted)\", delete the items from CoE (yes) or just mark deleted (no)",
        "ByLcid": {
          "1033": "Inventory - when we run \"Admin | Sync Template v2 (Check Deleted)\", delete the items from CoE (yes) or just mark deleted (no)"
        }
      }
    },
    {
      "SchemaName": "admin_DeveloperComplianceCenterURL",
      "Value": "${var.parameters.core.admin_developer_compliance_center_url}",
      "Name": {
        "Default": "Developer Compliance Center URL",
        "ByLcid": {
          "1033": "Developer Compliance Center URL"
        }
      },
      "Description": {
        "Default": "Compliance – LEAVE EMPTY ON IMPORT.  URL to Developer Compliance Center Canvas App. ",
        "ByLcid": {
          "1033": "Compliance – LEAVE EMPTY ON IMPORT.  URL to Developer Compliance Center Canvas App. "
        }
      }
    },
    {
      "SchemaName": "admin_DisabledUsersareOrphaned",
      "Value": "${var.parameters.core.admin_disabled_users_are_orphaned}",
      "DefaultValue": "no",
      "Name": {
        "Default": "Disabled Users are Orphaned",
        "ByLcid": {
          "1033": "Disabled Users are Orphaned"
        }
      },
      "Description": {
        "Default": "Inventory - If true (Yes), then when an AD User is marked as disabled (Account enabled = false), they will be considered as orphaned. Default is false (No)",
        "ByLcid": {
          "1033": "Inventory - If true (Yes), then when an AD User is marked as disabled (Account enabled = false), they will be considered as orphaned. Default is false (No)"
        }
      }
    },
    {
      "SchemaName": "admin_eMailBodyStart",
      "Value": "${var.parameters.core.admin_email_body_start}",
      "DefaultValue": "<body>     <div id='content'>         <table id='form'>             <tr>                 <td><img id='logo' src='https://upload.wikimedia.org/wikipedia/commons/thumb/9/96/Microsoft_logo_%282012%29.svg/1280px-Microsoft_logo_%282012%29.svg.png' width='300'></td>             </tr>             <tr>                 <td>                     <p id='header'>Power Platform</p>                 </td>             </tr>             <tr id='ribbon'>                 <td>                     <tr>                         <td></td>                     </tr>                     <tr id='message'>                         <td>",
      "Name": {
        "Default": "eMail Body Start",
        "ByLcid": {
          "1033": "eMail Body Start"
        }
      },
      "Description": {
        "Default": "Inventory - Starter HTML format for eMails",
        "ByLcid": {
          "1033": "Inventory - Starter HTML format for eMails"
        }
      }
    },
    {
      "SchemaName": "admin_eMailBodyStop",
      "Value": "${var.parameters.core.admin_email_body_stop}",
      "DefaultValue": "</td>                     </tr>         </table>     </div> </body>",
      "Name": {
        "Default": "eMail Body Stop",
        "ByLcid": {
          "1033": "eMail Body Stop"
        }
      },
      "Description": {
        "Default": "Inventory - Ending HTML format for eMails",
        "ByLcid": {
          "1033": "Inventory - Ending HTML format for eMails"
        }
      }
    },
    {
      "SchemaName": "admin_eMailHeaderStyle",
      "Value": "${var.parameters.core.admin_email_header_style}",
      "DefaultValue": "<head>     <style>         body {             background-color: #efefef;             font-family: Segoe UI;             text-align: center;         }          #content {             border: 1px solid #742774;             background-color: #ffffff;             width: 650px;             margin-bottom: 50px;             display: inline-block;         }          #logo {             margin-left: 52px;             margin-top: 40px;             width: 60px;             height: 12px;         }          #header {             font-size: 24px;             margin-left: 50px;             margin-top: 20px;             margin-bottom: 20px;         }          #ribbon {             background-color: #742774;         }          #ribbonContent {             font-size: 20px;             padding-left: 30px;             padding-top: 10px;             padding-bottom: 20px;             color: white;             width: 100%;             padding-right: 10px;         }          #message>td {             font-size: 14px;             padding-left: 60px;             padding-right: 60px;             padding-top: 20px;             padding-bottom: 40px;         }          #footer>td {             font-size: 12px;             background-color: #cfcfcf;             height: 40px;             padding-top: 15px;             padding-left: 40px;             padding-bottom: 20px;         }          #form {             width: 100%;             border-collapse: collapse;         }          #app {             width: 60%;             font-size: 12px;         }          .label {             color: #5f5f5f         }          table {             border-collapse: collapse;             width: 100%;         }          th,         td {             padding: 8px;             text-align: left;             border-bottom: 1px solid #ddd;         }     </style> </head>",
      "Name": {
        "Default": "eMail Header Style",
        "ByLcid": {
          "1033": "eMail Header Style"
        }
      },
      "Description": {
        "Default": "Inventory - CSS/Style used for eMails",
        "ByLcid": {
          "1033": "Inventory - CSS/Style used for eMails"
        }
      }
    },
    {
      "SchemaName": "admin_EnvironmentDataflowID",
      "Value": "${var.parameters.core.admin_environment_dataflow_id}",
      "Name": {
        "Default": "Environment Dataflow ID",
        "ByLcid": {
          "1033": "Environment Dataflow ID"
        }
      },
      "Description": {
        "Default": "LEAVE BLANK ON IMPORT. Dataflow ID of the CoE BYODL Environments dataflow.",
        "ByLcid": {
          "1033": "LEAVE BLANK ON IMPORT. Dataflow ID of the CoE BYODL Environments dataflow."
        }
      }
    },
    {
      "SchemaName": "admin_EnvRequestAutoApproveCertainGroups",
      "Value": "${var.parameters.core.admin_env_request_auto_approve_certain_groups}",
      "DefaultValue": "no",
      "Name": {
        "Default": "Env Request - Automatically Approve Certain Groups",
        "ByLcid": {
          "1033": "Env Request - Automatically Approve Certain Groups"
        }
      },
      "Description": {
        "Default": "Env Request - Enable to automatically approve creation requests for certain groups",
        "ByLcid": {
          "1033": "Env Request - Enable to automatically approve creation requests for certain groups"
        }
      }
    },
    {
      "SchemaName": "admin_EnvRequestEnableCostTracking",
      "Value": "${var.parameters.core.admin_env_request_enable_cost_tracking}",
      "DefaultValue": "no",
      "Name": {
        "Default": "Env Request - Enable Cost Tracking",
        "ByLcid": {
          "1033": "Env Request - Enable Cost Tracking"
        }
      },
      "Description": {
        "Default": "Env Request - Choose Yes to enable cost tracking in the Environment Creation Request form.",
        "ByLcid": {
          "1033": "Env Request - Choose Yes to enable cost tracking in the Environment Creation Request form."
        }
      }
    },
    {
      "SchemaName": "admin_FlowConnectionsDataflowID",
      "Value": "${var.parameters.core.admin_flow_connections_dataflow_id}",
      "Name": {
        "Default": "Flow Connections Dataflow ID",
        "ByLcid": {
          "1033": "Flow Connections Dataflow ID"
        }
      },
      "Description": {
        "Default": "LEAVE EMPTY ON IMPORT. Flow Connections Dataflow ID.",
        "ByLcid": {
          "1033": "LEAVE EMPTY ON IMPORT. Flow Connections Dataflow ID."
        }
      }
    },
    {
      "SchemaName": "admin_FlowDataflowID",
      "Value": "${var.parameters.core.admin_flow_dataflow_id}",
      "Name": {
        "Default": "Flow Dataflow ID",
        "ByLcid": {
          "1033": "Flow Dataflow ID"
        }
      },
      "Description": {
        "Default": "LEAVE BLANK ON IMPORT. Dataflow ID of the CoE BYODL Makers dataflow.",
        "ByLcid": {
          "1033": "LEAVE BLANK ON IMPORT. Dataflow ID of the CoE BYODL Makers dataflow."
        }
      }
    },
    {
      "SchemaName": "admin_FlowUsageDataflowID",
      "Value": "${var.parameters.core.admin_flow_usage_dataflow_id}",
      "Name": {
        "Default": "Flow Usage Dataflow ID",
        "ByLcid": {
          "1033": "Flow Usage Dataflow ID"
        }
      },
      "Description": {
        "Default": "LEAVE EMPTY ON IMPORT. Flow Usage Dataflow ID.",
        "ByLcid": {
          "1033": "LEAVE EMPTY ON IMPORT. Flow Usage Dataflow ID."
        }
      }
    },
    {
      "SchemaName": "admin_FullInventory",
      "Value": "${var.parameters.core.admin_full_inventory}",
      "DefaultValue": "no",
      "Name": {
        "Default": "FullInventory",
        "ByLcid": {
          "1033": "FullInventory"
        }
      },
      "Description": {
        "Default": "Inventory - Determines if you want to only update objects that have changed, or all objects. Defaults to No. Switching to Yes will cause the flows to inventory every single app/flow/etc in the tenant and make the flows long running ",
        "ByLcid": {
          "1033": "Inventory - Determines if you want to only update objects that have changed, or all objects. Defaults to No. Switching to Yes will cause the flows to inventory every single app/flow/etc in the tenant and make the flows long running "
        }
      }
    },
    {
      "SchemaName": "admin_GraphURLEnvironmentVariable",
      "Value": "${var.parameters.core.admin_graph_url_environment_variable}",
      "Name": {
        "Default": "Graph URL Environment Variable",
        "ByLcid": {
          "1033": "Graph URL Environment Variable"
        }
      },
      "Description": {
        "Default": "Inventory - REQUIRED. The URL used to get graph information for your cloud. Ex https://graph.microsoft.com/",
        "ByLcid": {
          "1033": "Inventory - REQUIRED. The URL used to get graph information for your cloud. Ex https://graph.microsoft.com/"
        }
      }
    },
    {
      "SchemaName": "admin_HostDomains",
      "Value": "${var.parameters.core.admin_host_domains}",
      "Name": {
        "Default": "Host Domains",
        "ByLcid": {
          "1033": "Host Domains"
        }
      },
      "Description": {
        "Default": "Domains to consider as local for cross domain identity reports. As a comma-separated string: myCo.onmicrosoft.com, partnerCo.onmicrosoft.com",
        "ByLcid": {
          "1033": "Domains to consider as local for cross domain identity reports. As a comma-separated string: myCo.onmicrosoft.com, partnerCo.onmicrosoft.com"
        }
      }
    },
    {
      "SchemaName": "admin_InventoryandTelemetryinAzureDataStorageaccount",
      "Value": "${var.parameters.core.admin_inventory_and_telemetry_in_azure_data_storage_account}",
      "DefaultValue": "no",
      "Name": {
        "Default": "Inventory and Telemetry in Azure Data Storage account",
        "ByLcid": {
          "1033": "Inventory and Telemetry in Azure Data Storage account"
        }
      },
      "Description": {
        "Default": "Inventory - Have you set up data export in PPAC and is your inventory and telemetry in an Azure Data Storage folder (also referred to as Bring your own Datalake, self-serve analytics feature). Default no",
        "ByLcid": {
          "1033": "Inventory - Have you set up data export in PPAC and is your inventory and telemetry in an Azure Data Storage folder (also referred to as Bring your own Datalake, self-serve analytics feature). Default no"
        }
      }
    },
    {
      "SchemaName": "admin_InventoryFilter_DaysToLookBack",
      "Value": "${var.parameters.core.admin_inventory_filter_days_to_look_back}",
      "DefaultValue": "7",
      "Name": {
        "Default": "InventoryFilter_DaysToLookBack",
        "ByLcid": {
          "1033": "InventoryFilter_DaysToLookBack"
        }
      },
      "Description": {
        "Default": "Inventory - When not running a full inventory, we filter back this number of days and then see if the object needs updated in order to save API calls. Default 7",
        "ByLcid": {
          "1033": "Inventory - When not running a full inventory, we filter back this number of days and then see if the object needs updated in order to save API calls. Default 7"
        }
      }
    },
    {
      "SchemaName": "admin_isFullTenantInventory",
      "Value": "${var.parameters.core.admin_is_full_tenant_inventory}",
      "DefaultValue": "yes",
      "Name": {
        "Default": "is All Environments Inventory",
        "ByLcid": {
          "1033": "is All Environments Inventory"
        }
      },
      "Description": {
        "Default": "Inventory - If true, (the default) the CoE inventory tracks all environments. New environments added to the inventory will have their Excuse from Inventory to false. You can opt out individual environments.  If false, the CoE inventory tracks a subset of environments. New environments added to the inventory will have their Excuse from Inventory to true. You can opt in individual environments.",
        "ByLcid": {
          "1033": "Inventory - If true, (the default) the CoE inventory tracks all environments. New environments added to the inventory will have their Excuse from Inventory to false. You can opt out individual environments.  If false, the CoE inventory tracks a subset of environments. New environments added to the inventory will have their Excuse from Inventory to true. You can opt in individual environments."
        }
      }
    },
    {
      "SchemaName": "admin_MakerDataflowID",
      "Value": "${var.parameters.core.admin_maker_dataflow_id}",
      "Name": {
        "Default": "Maker Dataflow ID",
        "ByLcid": {
          "1033": "Maker Dataflow ID"
        }
      },
      "Description": {
        "Default": "LEAVE BLANK ON IMPORT. Dataflow ID of the CoE BYODL Makers dataflow.",
        "ByLcid": {
          "1033": "LEAVE BLANK ON IMPORT. Dataflow ID of the CoE BYODL Makers dataflow."
        }
      }
    },
    {
      "SchemaName": "admin_ModelAppDataflowID",
      "Value": "${var.parameters.core.admin_model_app_dataflow_id}",
      "Name": {
        "Default": "Model App Dataflow ID",
        "ByLcid": {
          "1033": "Model App Dataflow ID"
        }
      },
      "Description": {
        "Default": "LEAVE BLANK ON IMPORT. Dataflow ID of the dataflow that processes model driven apps. Used for BYODL only.",
        "ByLcid": {
          "1033": "LEAVE BLANK ON IMPORT. Dataflow ID of the dataflow that processes model driven apps. Used for BYODL only."
        }
      }
    },
    {
      "SchemaName": "admin_PowerAppEnvironmentVariable",
      "Value": "${var.parameters.core.admin_power_app_environment_variable}",
      "Name": {
        "Default": "PowerApp Maker Environment Variable",
        "ByLcid": {
          "1033": "PowerApp Maker Environment Variable"
        }
      },
      "Description": {
        "Default": "Inventory - REQUIRED. The maker URL used by PowerApps for your cloud. Ex https://make.powerapps.com/",
        "ByLcid": {
          "1033": "Inventory - REQUIRED. The maker URL used by PowerApps for your cloud. Ex https://make.powerapps.com/"
        }
      }
    },
    {
      "SchemaName": "admin_PowerAppPlayerEnvironmentVariable",
      "Value": "${var.parameters.core.admin_power_app_player_environment_variable}",
      "Name": {
        "Default": "PowerApp Player Environment Variable",
        "ByLcid": {
          "1033": "PowerApp Player Environment Variable"
        }
      },
      "Description": {
        "Default": "Inventory - REQUIRED. The player URL used by PowerApps for your cloud. Ex https://apps.powerapps.com/",
        "ByLcid": {
          "1033": "Inventory - REQUIRED. The player URL used by PowerApps for your cloud. Ex https://apps.powerapps.com/"
        }
      }
    },
    {
      "SchemaName": "admin_PowerAutomateEnvironmentVariable",
      "Value": "${var.parameters.core.admin_power_automate_environment_variable}",
      "Name": {
        "Default": "Power Automate Environment Variable",
        "ByLcid": {
          "1033": "Power Automate Environment Variable"
        }
      },
      "Description": {
        "Default": "Inventory - REQUIRED. Environment, including geographic location, for Power Automate - Ex for commercial: https://flow.microsoft.com/manage/environments/",
        "ByLcid": {
          "1033": "Inventory - REQUIRED. Environment, including geographic location, for Power Automate - Ex for commercial: https://flow.microsoft.com/manage/environments/"
        }
      }
    },
    {
      "SchemaName": "admin_PowerPlatformMakeSecurityGroup",
      "Value": "${var.parameters.core.admin_power_platform_make_security_group}",
      "Name": {
        "Default": "Power Platform Maker Group ID",
        "ByLcid": {
          "1033": "Power Platform Maker Group ID"
        }
      },
      "Description": {
        "Default": "Inventory - Enter the ID of the Microsoft 365 group which will contain all your Power Platform Makers.  It is needed to communicate and share apps with them.",
        "ByLcid": {
          "1033": "Inventory - Enter the ID of the Microsoft 365 group which will contain all your Power Platform Makers.  It is needed to communicate and share apps with them."
        }
      }
    },
    {
      "SchemaName": "admin_PowerPlatformUserGroupID",
      "Value": "${var.parameters.core.admin_power_platform_user_group_id}",
      "Name": {
        "Default": "Power Platform User Group ID",
        "ByLcid": {
          "1033": "Power Platform User Group ID"
        }
      },
      "Description": {
        "Default": "Inventory - Enter the ID of the Microsoft 365 group which will contain all your Power Platform Users (for example, end users that apps are shared with).  It is needed to communicate and share apps with them.",
        "ByLcid": {
          "1033": "Inventory - Enter the ID of the Microsoft 365 group which will contain all your Power Platform Users (for example, end users that apps are shared with).  It is needed to communicate and share apps with them."
        }
      }
    },
    {
      "SchemaName": "admin_ProductionEnvironment",
      "Value": "${var.parameters.core.admin_production_environment}",
      "DefaultValue": "yes",
      "Name": {
        "Default": "ProductionEnvironment",
        "ByLcid": {
          "1033": "ProductionEnvironment"
        }
      },
      "Description": {
        "Default": "Inventory - Yes by default. Set to No if you are creating a dev type envt. This will allow some flows to set target users to the admin instead of resource owners",
        "ByLcid": {
          "1033": "Inventory - Yes by default. Set to No if you are creating a dev type envt. This will allow some flows to set target users to the admin instead of resource owners"
        }
      }
    },
    {
      "SchemaName": "admin_SyncFlowErrorsDeleteAfterXDays",
      "Value": "${var.parameters.core.admin_sync_flow_errors_delete_after_x_days}",
      "DefaultValue": "7",
      "Name": {
        "Default": "Sync Flow Errors Delete After X Days",
        "ByLcid": {
          "1033": "Sync Flow Errors Delete After X Days"
        }
      },
      "Description": {
        "Default": "Inventory - Number of days back to store sync flow error records. Will delete records older than this number of days. Default 7",
        "ByLcid": {
          "1033": "Inventory - Number of days back to store sync flow error records. Will delete records older than this number of days. Default 7"
        }
      }
    },
    {
      "SchemaName": "admin_TenantID",
      "Value": "${jsondecode(data.powerplatform_rest_query.org_details.output.body).Detail.TenantId}",
      "Name": {
        "Default": "TenantID",
        "ByLcid": {
          "1033": "TenantID"
        }
      },
      "Description": {
        "Default": "Inventory - REQUIRED. Azure Tenant ID",
        "ByLcid": {
          "1033": "Inventory - REQUIRED. Azure Tenant ID"
        }
      }
    },
    {
      "SchemaName": "admin_UserPhotosForbiddenByPolicy",
      "Value": "${var.parameters.core.admin_user_photos_forbidden_by_policy}",
      "DefaultValue": "no",
      "Name": {
        "Default": "DEPRECATED 0 User Photos ForbiddenByPolicy",
        "ByLcid": {
          "1033": "DEPRECATED 0 User Photos ForbiddenByPolicy"
        }
      },
      "Description": {
        "Default": "No longer used - True if the admin has forbidden user from querying for user photos. False by default",
        "ByLcid": {
          "1033": "No longer used - True if the admin has forbidden user from querying for user photos. False by default"
        }
      }
    },
    {
      "SchemaName": "coe_EnvironmentRequestAdminAppUrl",
      "Value": "${var.parameters.core.coe_environment_request_admin_app_url}",
      "Name": {
        "Default": "Environment Request Admin App Url",
        "ByLcid": {
          "1033": "Environment Request Admin App Url"
        }
      },
      "Description": {
        "Default": "Env Request - LEAVE EMPTY ON IMPORT. URL to Environment Request Admin Canvas App.",
        "ByLcid": {
          "1033": "Env Request - LEAVE EMPTY ON IMPORT. URL to Environment Request Admin Canvas App."
        }
      }
    }
  ],
  ${var.parameters.conn.connection_create_mode == "terraform" ? local.terraform_connections_output : local.test_engine_connections_output}
}
EOF
}
