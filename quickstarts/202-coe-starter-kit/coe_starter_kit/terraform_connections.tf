resource "powerplatform_connection" "connection_object" {

  
  for_each = {
    for logicalName, conn in local.all_connections : conn.logicalName => conn
    if var.parameters.conn.should_create_connections == true && var.parameters.conn.connection_create_mode == "terraform"
  } 

  provider = powerplatform.pp
  environment_id = var.parameters.env.env_id
  name           = each.value.name
  display_name   = each.value.display_name
  connection_parameters = each.value.connection_parameters
  connection_parameters_set = each.value.connection_parameters_set

  lifecycle {
    ignore_changes = [
      connection_parameters,
      connection_parameters_set
    ]
  }
}

resource "powerplatform_connection_share" "share_with_admin" {

  for_each = {
    for id, conn in powerplatform_connection.connection_object : id => {
      name = conn["name"]
      id = conn["id"]
    }
    if var.parameters.conn.connection_share_with_object_id != "" 
    && var.parameters.conn.connection_share_with_object_id != null
    && var.parameters.conn.connection_share_with_object_id != "00000000-0000-0000-0000-000000000000"
    && var.parameters.conn.connection_share_permissions != ""
    && var.parameters.conn.connection_share_permissions != null
    && var.parameters.conn.should_create_connections == true
    && var.parameters.conn.connection_create_mode == "terraform"
  }

  provider = powerplatform.pp
  environment_id = var.parameters.env.env_id
  connector_name = powerplatform_connection.connection_object[each.key].name
  connection_id  = powerplatform_connection.connection_object[each.key].id
  role_name      = var.parameters.conn.connection_share_permissions
  principal = {
    entra_object_id = var.parameters.conn.connection_share_with_object_id
  }
}

locals {
  terraform_connections_output = <<EOF
 "ConnectionReferences": [
    {
      "LogicalName": "admin_CoEBYODLDataverse",
      "ConnectionId": "${var.parameters.conn.should_create_connections == true && var.parameters.conn.connection_create_mode == "terraform" ? powerplatform_connection.connection_object["admin_CoEBYODLDataverse"].id : ""}",
      "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_commondataserviceforapps"
    },
    {
      "LogicalName": "admin_CoEBYODLPowerQuery",
      "ConnectionId": "${var.parameters.conn.should_create_connections == true && var.parameters.conn.connection_create_mode == "terraform" ? powerplatform_connection.connection_object["admin_CoEBYODLPowerQuery"].id : ""}",
      "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_dataflows"
    },
    {
      "LogicalName": "admin_CoECoreDataverse",
      "ConnectionId": "${var.parameters.conn.should_create_connections == true && var.parameters.conn.connection_create_mode == "terraform" ? powerplatform_connection.connection_object["admin_CoECoreDataverse"].id : ""}",
      "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_commondataserviceforapps"
    },
    {
      "LogicalName": "admin_CoECoreDataverse2",
      "ConnectionId": "${var.parameters.conn.should_create_connections == true && var.parameters.conn.connection_create_mode == "terraform" ? powerplatform_connection.connection_object["admin_CoECoreDataverse2"].id : ""}",
      "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_commondataserviceforapps"
    },
    {
      "LogicalName": "admin_CoECoreDataverseEnvRequest",
      "ConnectionId": "${var.parameters.conn.should_create_connections == true && var.parameters.conn.connection_create_mode == "terraform" ? powerplatform_connection.connection_object["admin_CoECoreDataverseEnvRequest"].id : ""}",
      "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_commondataserviceforapps"
    },
    {
      "LogicalName": "admin_CoECoreDataverseForApps",
      "ConnectionId": "${var.parameters.conn.should_create_connections == true && var.parameters.conn.connection_create_mode == "terraform" ? powerplatform_connection.connection_object["admin_CoECoreDataverseForApps"].id : ""}",
      "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_commondataserviceforapps"
    },
    {
      "LogicalName": "admin_CoECoreHTTPWithAzureAD",
      "ConnectionId": "${var.parameters.conn.should_create_connections == true && var.parameters.conn.connection_create_mode == "terraform" ? powerplatform_connection.connection_object["admin_CoECoreHTTPWithAzureAD"].id : ""}",
      "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_webcontents"
    },
    {
      "LogicalName": "admin_CoECoreO365Groups",
      "ConnectionId": "${var.parameters.conn.should_create_connections == true && var.parameters.conn.connection_create_mode == "terraform" ? powerplatform_connection.connection_object["admin_CoECoreO365Groups"].id : ""}",
      "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_office365groups"
    },
    {
      "LogicalName": "admin_CoECoreO365Outlook",
      "ConnectionId": "${var.parameters.conn.should_create_connections == true && var.parameters.conn.connection_create_mode == "terraform" ? powerplatform_connection.connection_object["admin_CoECoreO365Outlook"].id : ""}",
      "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_office365"
    },
    {
      "LogicalName": "admin_CoECoreO365Users",
      "ConnectionId": "${var.parameters.conn.should_create_connections == true && var.parameters.conn.connection_create_mode == "terraform" ? powerplatform_connection.connection_object["admin_CoECoreO365Users"].id : ""}",
      "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_office365users"
    },
    {
      "LogicalName": "admin_CoECoreOffice365Users",
      "ConnectionId": "${var.parameters.conn.should_create_connections == true && var.parameters.conn.connection_create_mode == "terraform" ? powerplatform_connection.connection_object["admin_CoECoreOffice365Users"].id : ""}",
      "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_office365users"
    },
    {
      "LogicalName": "admin_CoECorePowerAppsAdmin",
      "ConnectionId": "${var.parameters.conn.should_create_connections == true && var.parameters.conn.connection_create_mode == "terraform" ? powerplatform_connection.connection_object["admin_CoECorePowerAppsAdmin"].id : ""}",
      "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_powerappsforadmins"
    },
    {
      "LogicalName": "admin_CoECorePowerAppsAdmin2",
      "ConnectionId": "${var.parameters.conn.should_create_connections == true && var.parameters.conn.connection_create_mode == "terraform" ? powerplatform_connection.connection_object["admin_CoECorePowerAppsAdmin2"].id : ""}",
      "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_powerappsforadmins"
    },
    {
      "LogicalName": "admin_CoECorePowerAppsMakers",
      "ConnectionId": "${var.parameters.conn.should_create_connections == true && var.parameters.conn.connection_create_mode == "terraform" ? powerplatform_connection.connection_object["admin_CoECorePowerAppsMakers"].id : ""}",
      "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_powerappsforappmakers"
    },
    {
      "LogicalName": "admin_CoECorePowerAutomateAdmin",
      "ConnectionId": "${var.parameters.conn.should_create_connections == true && var.parameters.conn.connection_create_mode == "terraform" ? powerplatform_connection.connection_object["admin_CoECorePowerAutomateAdmin"].id : ""}",
      "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_microsoftflowforadmins"
    },
    {
      "LogicalName": "admin_CoECorePowerAutomateManagement",
      "ConnectionId": "${var.parameters.conn.should_create_connections == true && var.parameters.conn.connection_create_mode == "terraform" ? powerplatform_connection.connection_object["admin_CoECorePowerAutomateManagement"].id : ""}",
      "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_flowmanagement"
    },
    {
      "LogicalName": "admin_CoECorePowerPlatformforAdmins",
      "ConnectionId": "${var.parameters.conn.should_create_connections == true && var.parameters.conn.connection_create_mode == "terraform" ? powerplatform_connection.connection_object["admin_CoECorePowerPlatformforAdmins"].id : ""}",
      "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_powerplatformforadmins"
    },
    {
      "LogicalName": "admin_CoECorePowerPlatformforAdminsEnvRequest",
      "ConnectionId": "${var.parameters.conn.should_create_connections == true && var.parameters.conn.connection_create_mode == "terraform" ? powerplatform_connection.connection_object["admin_CoECorePowerPlatformforAdminsEnvRequest"].id : ""}",
      "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_powerplatformforadmins"
    },
    {
      "LogicalName": "admin_CoECoreTeams",
      "ConnectionId": "${var.parameters.conn.should_create_connections == true && var.parameters.conn.connection_create_mode == "terraform" ? powerplatform_connection.connection_object["admin_CoECoreTeams"].id : ""}",
      "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_teams"
    },
    {
      "LogicalName": "admin_sharedcommondataserviceforapps_98924",
      "ConnectionId": "${var.parameters.conn.should_create_connections == true && var.parameters.conn.connection_create_mode == "terraform" ? powerplatform_connection.connection_object["admin_sharedcommondataserviceforapps_98924"].id : ""}",
      "ConnectorId": "/providers/Microsoft.PowerApps/apis/shared_commondataserviceforapps"
    }
  ]
EOF
}