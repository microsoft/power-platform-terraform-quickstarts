terraform {
  required_providers {
    powerplatform = {
      source  = "microsoft/power-platform"
      version = "0.5.0-preview"
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
  domain            = "myspecialfoodomain"
}

resource "powerplatform_managed_environment" "foo_managed" {
  environment_id             = powerplatform_environment.foo.id
  is_usage_insights_disabled = true
  is_group_sharing_disabled  = true
  limit_sharing_mode         = "ExcludeSharingToSecurityGroups"
  max_limit_user_sharing     = 10
  solution_checker_mode      = "None"
  suppress_validation_emails = true
  maker_onboarding_markdown  = "this is example markdown"
  maker_onboarding_url       = "https://www.microsoft.com"
}