terraform {
  required_providers {
    powerplatform = {
      source = "microsoft/power-platform"
      version = "2.7.0-preview"
    }
  }
}

provider "powerplatform" {
  use_cli = true
}

#---- 1 - Set key tenant settings

resource "powerplatform_tenant_settings" "settings" {

  power_platform = {
    power_automate = {
      disable_copilot           = false
      # Optional
      disable_copilot_with_bing = false
    }
    intelligence = {
      disable_copilot                   = false
      enable_open_ai_bot_publishing     = true
    }
  }
}

#---- 2 - Generate a new Power Platform environment ----

resource "powerplatform_environment" "dev" {
  location          = var.powerplatform_location
  display_name      = var.environment_display_name
  environment_type  = var.environment_type
  dataverse = {
    language_code     = var.language_code
    currency_code     = var.currency_code
    security_group_id = var.environment_access_group_id
  }
}

#---- 3 - Add the service principal to the environment ----

# # Find the environment-specific record ID for the relevant role
data "powerplatform_data_records" "environment_maker_role" {
  environment_id = powerplatform_environment.dev.id
  entity_collection = "roles"
  filter = "name eq 'Environment Maker'"
  select = ["roleidunique"]
}

data "powerplatform_data_records" "business_units" {
  environment_id = powerplatform_environment.dev.id
  entity_collection = "businessunits"
  select = ["businessunitid"]
}

# TODO come up with a plan for create AND update that's better than "comment this out"
# Add a user record and connect that record to the desired role(s)
resource "powerplatform_data_record" "service_principal_user" {
  table_logical_name = "systemuser"
  environment_id     = powerplatform_environment.dev.id
  columns = {
    applicationid = var.admin_id
    businessunitid = {
      table_logical_name = "businessunit"
      data_record_id     = data.powerplatform_data_records.business_units.rows[0].businessunitid
    }
    systemuserroles_association = [{table_logical_name = "role", data_record_id = data.powerplatform_data_records.environment_maker_role.rows[0].roleid}]
  }
}

resource "powerplatform_user" "principal_user" {
  environment_id = powerplatform_environment.dev.id
  security_roles = [
    "d58407f2-48d5-e711-a82c-000d3a37c848"
  ]
  aad_id = var.admin_id
  disable_delete = false
}

#---- 4 - Set up Power Platform connector ----

# Create the connection
resource "powerplatform_connection" "azure_openai_connection" {
  environment_id = powerplatform_environment.dev.id
  # This is the connector type and should not be changed in this example
  name           = "shared_azureopenai"
  display_name   = var.connection_display_name
  connection_parameters = jsonencode({
    "azureOpenAIResourceName" : var.oai_resource_name,
    "azureOpenAIApiKey" : var.oai_api_key,
    "azureSearchEndpointUrl" : var.search_endpoint_uri,
    "azureSearchApiKey" : var.search_api_key
  })

  lifecycle {
    ignore_changes = [
      connection_parameters
    ]
  }
}

# This connection may have been created by a service principal, so for visibility 
# it can optionally be shared with an admin user. If the admin user's credentials were
# used to create the connection, this step is not necessary.
resource "powerplatform_connection_share" "share_with_admin" {
  environment_id = powerplatform_environment.dev.id
  connector_name = powerplatform_connection.azure_openai_connection.name
  connection_id  = powerplatform_connection.azure_openai_connection.id
  role_name      = "CanEdit"
  principal = {
    entra_object_id = var.admin_id
  }
}

#---- 5 - Set up Dataverse record for the Copilot ----

resource "powerplatform_data_record" "copilot" {
  depends_on = [ powerplatform_user.principal_user ]
  environment_id     = powerplatform_environment.dev.id
  table_logical_name = "bot"
  columns = {
    name        = var.copilot_name
    configuration = "{\n  \"$kind\" : \"BotConfiguration\",\n  \"publishOnCreate\" : true,\n  \"settings\" : {\n  \"GenerativeActionsEnabled\" : false,\n  },\n  \"isLightweightBot\" : true\n}"
  }
}

#---- 6 - Future state: base bot configuration eventually needs model knowledge source ----