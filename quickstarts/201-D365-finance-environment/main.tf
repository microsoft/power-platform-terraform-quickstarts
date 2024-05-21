terraform {
  required_version = ">= 1.5"
  required_providers {
    power-platform = {
      source = "microsoft/power-platform"
    }
  }
}

provider "power-platform" {
  use_cli = true
}


resource "power-platform_environment" "xpp-dev1" {
  display_name     = var.d365_finance_environment_name
  location         = var.location
  environment_type = var.environment_type
  templates = ["D365_FinOps_Finance"]
  template_metadata = "{\"PostProvisioningPackages\": [{ \"applicationUniqueName\": \"msdyn_FinanceAndOperationsProvisioningAppAnchor\",\n \"parameters\": \"DevToolsEnabled=true|DemoDataEnabled=true\"\n }\n ]\n }"
  dataverse = {
    language_code     = var.language_code
    currency_code     = var.currency_code
    security_group_id = "00000000-0000-0000-0000-000000000000"
  }
}
