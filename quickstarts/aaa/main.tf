terraform {
  required_providers {
    powerplatform = {
      source = "microsoft/power-platform"
      version = "2.4.1-preview"
    }
    github = {
      source = "integrations/github"
      version = "6.2.2"
    }
  }
}

provider "powerplatform" {
  use_cli = true
}

provider "github" {
}

locals {
  get_latest = true
  asset_url = [for i in data.github_release.example.assets : i if i.name == "CreatorKit.zip"]
}

data "github_release" "example" {
    repository  = "powercat-creator-kit"
    owner       = "microsoft"
    retrieve_by = local.get_latest == true ? "latest" : "tag"
    release_tag = "CreatorKit-May2024"
}

output "name" {
  value = local.asset_url
}



