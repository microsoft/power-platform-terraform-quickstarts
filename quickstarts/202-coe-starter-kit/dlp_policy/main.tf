terraform {
  required_providers {
    powerplatform = {
      source                = "microsoft/power-platform"
      configuration_aliases = [powerplatform.pp]
    }
  }
}

data "powerplatform_connectors" "all_connectors" {
  provider = powerplatform.pp
}

locals {
  business_connectors = toset([
    {
      action_rules                 = []
      default_action_rule_behavior = ""
      endpoint_rules               = []
      id                           = "/providers/Microsoft.PowerApps/apis/shared_commondataserviceforapps"
    },
    {
      action_rules                 = []
      default_action_rule_behavior = ""
      endpoint_rules               = []
      id                           = "/providers/Microsoft.PowerApps/apis/shared_flowmanagement"
    },
    {
      action_rules                 = []
      default_action_rule_behavior = ""
      endpoint_rules               = []
      id                           = "/providers/Microsoft.PowerApps/apis/shared_microsoftflowforadmins"
    },
    {
      action_rules                 = []
      default_action_rule_behavior = ""
      endpoint_rules               = []
      id                           = "/providers/Microsoft.PowerApps/apis/shared_office365"
    },
    {
      action_rules                 = []
      default_action_rule_behavior = ""
      endpoint_rules               = []
      id                           = "/providers/Microsoft.PowerApps/apis/shared_office365groups"
    },
    {
      action_rules                 = []
      default_action_rule_behavior = ""
      endpoint_rules               = []
      id                           = "/providers/Microsoft.PowerApps/apis/shared_office365users"
    },
    {
      action_rules                 = []
      default_action_rule_behavior = ""
      endpoint_rules               = []
      id                           = "/providers/Microsoft.PowerApps/apis/shared_powerappsforadmins"
    },
    {
      action_rules                 = []
      default_action_rule_behavior = ""
      endpoint_rules               = []
      id                           = "/providers/Microsoft.PowerApps/apis/shared_powerappsforappmakers"
    },
    {
      action_rules                 = []
      default_action_rule_behavior = ""
      endpoint_rules               = []
      id                           = "/providers/Microsoft.PowerApps/apis/shared_powerplatformforadmins"
    },
    {
      action_rules                 = []
      default_action_rule_behavior = ""
      endpoint_rules               = []
      id                           = "/providers/Microsoft.PowerApps/apis/shared_rss"
    },
    {
      action_rules                 = []
      default_action_rule_behavior = ""
      endpoint_rules               = []
      id                           = "/providers/Microsoft.PowerApps/apis/shared_dataflows"
    },
    {
      action_rules                 = []
      default_action_rule_behavior = ""
      endpoint_rules               = []
      id                           = "/providers/Microsoft.PowerApps/apis/shared_webcontents"
    },
    {
      action_rules                 = []
      default_action_rule_behavior = ""
      endpoint_rules               = []
      id                           = "/providers/Microsoft.PowerApps/apis/shared_arm"
    },
    {
      action_rules                 = []
      default_action_rule_behavior = ""
      endpoint_rules               = []
      id                           = "/providers/Microsoft.PowerApps/apis/shared_approvals"
    },
    {
      action_rules                 = []
      default_action_rule_behavior = ""
      endpoint_rules               = []
      id                           = "/providers/Microsoft.PowerApps/apis/shared_commondataservice"
    },
      {
      action_rules                 = []
      default_action_rule_behavior = ""
      endpoint_rules               = []
      id                           = "/providers/Microsoft.PowerApps/apis/shared_powerplatformadminv2"
    },
      {
      action_rules                 = []
      default_action_rule_behavior = ""
      endpoint_rules               = []
      id                           = "/providers/Microsoft.PowerApps/apis/shared_teams"
    },
      {
      action_rules                 = []
      default_action_rule_behavior = ""
      endpoint_rules               = []
      id                           = "Http"
    },
  ])

  non_business_connectors = toset([for conn
    in data.powerplatform_connectors.all_connectors.connectors :
    {
      id                           = conn.id
      name                         = conn.name
      default_action_rule_behavior = ""
      action_rules                 = [],
      endpoint_rules               = []
    }
    if conn.unblockable == true && !contains([for bus_conn in local.business_connectors : bus_conn.id], conn.id)
  ])

  blocked_connectors = toset([for conn
    in data.powerplatform_connectors.all_connectors.connectors :
    {
      id                           = conn.id
      default_action_rule_behavior = ""
      action_rules                 = [],
      endpoint_rules               = []
    }
  if conn.unblockable == false && !contains([for bus_conn in local.business_connectors : bus_conn.id], conn.id)])
}

resource "powerplatform_data_loss_prevention_policy" "my_policy" {
  count = var.should_create_dlp_policy ? 1 : 0
  provider                          = powerplatform.pp
  display_name                      = "CoE Environment Policy"
  default_connectors_classification = "Blocked"
  environment_type                  = "OnlyEnvironments"
  environments                      = [var.environment_id]

  business_connectors     = local.business_connectors
  non_business_connectors = local.non_business_connectors
  blocked_connectors      = local.blocked_connectors

  custom_connectors_patterns = toset([
    {
      order            = 1
      host_url_pattern = "*"
      data_group       = "Ignore"
    }
  ])
}
