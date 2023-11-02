terraform {
  required_providers {
    azuread = {
      source = "hashicorp/azuread"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

data "azuread_domains" "aad_domains" {
  only_initial = true
}

locals {
  domain_name = data.azuread_domains.aad_domains.domains[0].domain_name
}

resource "random_password" "passwords" {
  count            = length(var.aliases)
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "azuread_user" "example" {
  count               = length(var.aliases)
  user_principal_name = "${var.aliases[count.index]}@${local.domain_name}"
  display_name        = var.aliases[count.index]
  mail_nickname       = var.aliases[count.index]
  password            = random_password.passwords[count.index].result
}