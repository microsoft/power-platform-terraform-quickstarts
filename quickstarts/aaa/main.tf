terraform {
  required_providers {
    powerplatform = {
      source = "microsoft/power-platform"
      version = "2.4.1-preview"
    }
  }
}

provider "powerplatform" {
use_cli = true
}


data "powerplatform_environments" "all_environments" {}
