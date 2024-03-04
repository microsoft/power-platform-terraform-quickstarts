terraform {
  required_version = ">= 1.5"
  required_providers {
    powerplatform = {
      source = "microsoft/power-platform"
    }
  }
}

provider "powerplatform" {
  use_cli = true
}


resource "powerplatform_environment" "xpp-dev1" {
  display_name     = var.d365_finance_environment_name
  location         = var.location
  language_code    = var.language_code
  currency_code    = var.currency_code
  environment_type = var.environment_type
  templates = ["D365_FinOps_Finance"]
  template_metadata = "{\"PostProvisioningPackages\": [{ \"applicationUniqueName\": \"msdyn_FinanceAndOperationsProvisioningAppAnchor\",\n \"parameters\": \"DevToolsEnabled=true|DemoDataEnabled=true\"\n }\n ]\n }"
}
