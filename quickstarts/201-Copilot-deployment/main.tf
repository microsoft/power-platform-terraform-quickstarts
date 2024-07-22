terraform {
  required_providers {
    power-platform = {
      source = "microsoft/power-platform"
      version = "2.6.1-preview"
    }
  }
}

provider "power-platform" {
  use_cli = true
}

resource "powerplatform_tenant_settings" "settings" {

  power_platform = {
    power_automate = {
      disable_copilot           = false
      disable_copilot_with_bing = false
    }
    intelligence = {
      disable_copilot                   = false
      enable_open_ai_bot_publishing     = true
    }
  }
}
