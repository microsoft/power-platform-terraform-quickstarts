terraform {
  required_providers {
    powerplatform = {
      source = "microsoft/power-platform"
      version = "2.6.2-preview"
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

#---- 3 - Set up Power Platform connector ----

#TODO waiting on Mateusz

#---- 4 - Set up Dataverse record for the Copilot ----

resource "powerplatform_data_record" "copilot" {
  environment_id     = powerplatform_environment.dev.id
  table_logical_name = "bot"
  columns = {
    name        = var.copilot_name
    configuration = "{\n  \"$kind\" : \"BotConfiguration\",\n  \"publishOnCreate\" : true,\n  \"settings\" : {\n  \"GenerativeActionsEnabled\" : false,\n  },\n  \"isLightweightBot\" : true\n}"
  }
}

#---- 5 - Future state: base bot configuration eventually needs model knowledge source ----