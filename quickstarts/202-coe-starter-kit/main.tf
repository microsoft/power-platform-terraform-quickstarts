terraform {
  required_providers {
    powerplatform = {
      source = "microsoft/power-platform"
    }
  }
}


provider "powerplatform" {
  use_cli = true
}

//dowload the solutions
resource "null_resource" "download_solutions" {
  provisioner "local-exec" {
    command = "wget -O ${path.module}/coe-starter-kit.zip https://aka.ms/CoEStarterKitDownload"
    when    = create
  }
  //TOOD: this assumes that we are running in a linux environment, consider adding support for windows
  provisioner "local-exec" {
    command = "rm -f ${path.module}/coe-starter-kit.zip"
    when    = destroy
  }
}

//extract the solutions
resource "null_resource" "extract_solutions_zip" {
  provisioner "local-exec" {
    command = "unzip -o ${path.module}/coe-starter-kit.zip -d ${path.module}/coe-starter-kit-extracted"
    when    = create
  }

  //TODO: this assumes that we are running in a linux environment, consider adding support for windows
  provisioner "local-exec" {
    command = "rm -rf ${path.module}/coe-starter-kit-extracted"
    when    = destroy
  }

  depends_on = [null_resource.download_solutions]
}

//because CenterofExcellenceCoreComponents_X_X.managed is in a specific version, we have to rename it to a fixed name
resource "null_resource" "rename_center_of_excellence_core_components_solution" {
  provisioner "local-exec" {
    command = <<-EOT
      cd ${path.module}/coe-starter-kit-extracted && mv CenterofExcellenceCoreComponents*.zip CenterofExcellenceCoreComponents.zip
    EOT
    when    = create
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
  unique_name    = data.powerplatform_tenant_application_packages.creator_kit_app.applications[0].unique_name
}

//create coe-kit-prod environment
resource "powerplatform_environment" "coe-kit-prod" {
  location         = "europe"
  display_name     = "coe-kit-prod"
  environment_type = "Sandbox"
  dataverse = {
    language_code     = 1033
    currency_code     = "USD"
    security_group_id = "00000000-0000-0000-0000-000000000000"
  }
}

//create coe-kit-test environment
# resource "powerplatform_environment" "coe-kit-test" {
#   location          = "europe"
#   display_name      = "coe-kit-test"
#   environment_type  = "Sandbox"
#   dataverse = {
#     language_code     = 1033
#     currency_code     = "USD"
#     security_group_id = "00000000-0000-0000-0000-000000000000"
#   }
# }


//TODO: setup DLP policies and assing to environments
//https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup#validate-data-loss-prevention-dlp-policies

//TODO: setup connections using script and maybe test engine?
//https://learn.microsoft.com/en-us/power-platform/guidance/coe/setup-core-components#create-connections


resource "powerplatform_solution" "solution" {
  environment_id = powerplatform_environment.coe-kit-prod.id
  solution_file  = "${path.module}/coe-starter-kit-extracted/CenterofExcellenceCoreComponents.zip"
  solution_name  = "CenterofExcellenceCoreComponents"
  settings_file  = local_file.solution_settings_file.filename

  depends_on = [null_resource.rename_center_of_excellence_core_components_solution]
}

//this file is generated using:
//pac solution create-settings --solution-zip .\CenterofExcellenceCoreComponents_4_32_2_managed.zip --settings-file out.json
//TODO: for connections we need a connectionid of each existing connection
//TODO: for env variables we need to expose them as script's input variables, unless something can be read from current 
//script context such as `admin_CurrentEnvironment`
resource "local_file" "solution_settings_file" {
  filename = "${path.module}/CenterofExcellenceCoreComponents_solution_settings_prod.json"
  content  = <<EOF
{
  "EnvironmentVariables": [
    {
      "SchemaName": "admin_AdmineMailPreferredLanguage",
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "${powerplatform_environment.coe-kit-prod.id}",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
      "Value": "",
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
   "ConnectionReferences": [
    {
      "LogicalName": "admin_CoEBYODLDataverse",
      "ConnectionId": "",
      "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_commondataserviceforapps"
    },
    {
      "LogicalName": "admin_CoEBYODLPowerQuery",
      "ConnectionId": "",
      "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_dataflows"
    },
    {
      "LogicalName": "admin_CoECoreDataverse",
      "ConnectionId": "",
      "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_commondataserviceforapps"
    },
    {
      "LogicalName": "admin_CoECoreDataverse2",
      "ConnectionId": "",
      "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_commondataserviceforapps"
    },
    {
      "LogicalName": "admin_CoECoreDataverseEnvRequest",
      "ConnectionId": "",
      "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_commondataserviceforapps"
    },
    {
      "LogicalName": "admin_CoECoreDataverseForApps",
      "ConnectionId": "",
      "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_commondataserviceforapps"
    },
    {
      "LogicalName": "admin_CoECoreHTTPWithAzureAD",
      "ConnectionId": "",
      "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_webcontents"
    },
    {
      "LogicalName": "admin_CoECoreO365Groups",
      "ConnectionId": "",
      "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_office365groups"
    },
    {
      "LogicalName": "admin_CoECoreO365Outlook",
      "ConnectionId": "",
      "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_office365"
    },
    {
      "LogicalName": "admin_CoECoreO365Users",
      "ConnectionId": "",
      "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_office365users"
    },
    {
      "LogicalName": "admin_CoECoreOffice365Users",
      "ConnectionId": "",
      "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_office365users"
    },
    {
      "LogicalName": "admin_CoECorePowerAppsAdmin",
      "ConnectionId": "",
      "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_powerappsforadmins"
    },
    {
      "LogicalName": "admin_CoECorePowerAppsAdmin2",
      "ConnectionId": "",
      "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_powerappsforadmins"
    },
    {
      "LogicalName": "admin_CoECorePowerAppsMakers",
      "ConnectionId": "",
      "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_powerappsforappmakers"
    },
    {
      "LogicalName": "admin_CoECorePowerAutomateAdmin",
      "ConnectionId": "",
      "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_microsoftflowforadmins"
    },
    {
      "LogicalName": "admin_CoECorePowerAutomateManagement",
      "ConnectionId": "",
      "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_flowmanagement"
    },
    {
      "LogicalName": "admin_CoECorePowerPlatformforAdmins",
      "ConnectionId": "",
      "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_powerplatformforadmins"
    },
    {
      "LogicalName": "admin_CoECorePowerPlatformforAdminsEnvRequest",
      "ConnectionId": "",
      "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_powerplatformforadmins"
    },
    {
      "LogicalName": "admin_CoECoreTeams",
      "ConnectionId": "",
      "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_teams"
    },
    {
      "LogicalName": "admin_sharedcommondataserviceforapps_98924",
      "ConnectionId": "",
      "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_commondataserviceforapps"
    }
  ]
}
EOF
}
