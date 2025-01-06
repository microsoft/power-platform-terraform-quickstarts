terraform {
  required_providers {
    powerplatform = {
      source  = "microsoft/power-platform"
       version = ">=3.3.0"
    }
  }
}

resource "powerplatform_environment" "dev" {
  location          = "unitedstates"
  display_name      = "terraformdev"
  environment_type  = "Sandbox"
  dataverse = {
    language_code     = 1033
    currency_code     = "USD"
    security_group_id = var.dev_environment_access_group_id
  }
}

resource "powerplatform_managed_environment" "dev_managed" {
  environment_id             = powerplatform_environment.dev.id
  is_usage_insights_disabled = true
  is_group_sharing_disabled  = true
  limit_sharing_mode         = "ExcludeSharingToSecurityGroups"
  max_limit_user_sharing     = 10
  solution_checker_mode      = "None"
  suppress_validation_emails = true
  maker_onboarding_markdown  = "Welcome to the ${powerplatform_environment.dev.display_name} environment!"
  maker_onboarding_url       = "https://www.contoso.com/onboarding"
}

resource "powerplatform_environment" "test" {
  location          = "unitedstates"
  display_name      = "terraformtest"
  environment_type  = "Sandbox"
  dataverse = {
    language_code     = 1033
    currency_code     = "USD"
    security_group_id = var.test_environment_access_group_id
  }
}

resource "powerplatform_managed_environment" "test_managed" {
  environment_id             = powerplatform_environment.test.id
  is_usage_insights_disabled = false
  is_group_sharing_disabled  = false
  limit_sharing_mode         = "ExcludeSharingToSecurityGroups"
  max_limit_user_sharing     = 100
  solution_checker_mode      = "None"
  suppress_validation_emails = false
  maker_onboarding_markdown  = "Welcome to the ${powerplatform_environment.test.display_name} environment!"
  maker_onboarding_url       = "https://www.contoso.com/onboarding"
}
