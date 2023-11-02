terraform {
  required_providers {
    powerplatform = {
      source  = "microsoft/power-platform"
      version = "0.3.0-preview"
    }
  }
}

resource "powerplatform_environment" "foo" {
  location          = "unitedstates"
  language_code     = 1033
  display_name      = "foo"
  currency_code     = "USD"
  environment_type  = "Sandbox"
  security_group_id = "00000000-0000-0000-0000-000000000000"
  domain            = "myspecialdomain"
}