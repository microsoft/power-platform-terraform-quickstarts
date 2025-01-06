terraform {
  required_version = ">= 1.5"
  required_providers {
    powerplatform = {
      source = "microsoft/power-platform"
      version = ">=3.3.0"
    }
  }
}

provider "powerplatform" {
  use_cli = true
}


resource "powerplatform_environment" "xpp-dev1" {
  display_name     = var.d365_finance_environment_name
  location         = var.location
  environment_type = var.environment_type
  dataverse = {
    templates = ["D365_FinOps_Finance"]
    template_metadata = "{\"PostProvisioningPackages\": [{ \"applicationUniqueName\": \"msdyn_FinanceAndOperationsProvisioningAppAnchor\",\n \"parameters\": \"DevToolsEnabled=true|DemoDataEnabled=true\"\n }\n ]\n }"
    language_code     = var.language_code
    currency_code     = var.currency_code
    security_group_id = var.security_group_id
  }
}