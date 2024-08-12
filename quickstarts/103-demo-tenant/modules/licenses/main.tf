# Retrieve an access token using an external PowerShell script
data "external" "access_token" {
  program = ["pwsh", "./get_graph_access_token.ps1"]
}

# Fetch the assigned licenses for a specific group from Microsoft Graph API
data "http" "group_assigned_plans" {
  url = "https://graph.microsoft.com/v1.0/groups/${var.group_id}/assignedLicenses"
  request_headers = {
    Authorization = "Bearer ${data.external.access_token.result.accessToken}"
  }
}

# Determine which SKUs are missing from the group's assigned licenses
locals {
  missing_skus = [for sku in var.license_skus : sku if !(contains([for plan in jsondecode(data.http.group_assigned_plans.response_body).value : plan.skuId], sku))]
}

# Assign missing licenses to the group using a null resource and local-exec provisioner
resource "null_resource" "assign_license" {
  count = length(local.missing_skus) > 0 ? 1 : 0

  provisioner "local-exec" {
    command = <<EOT
      pwsh ./assign_license.ps1 -groupId ${var.group_id} -licenseSkus ${join(",", local.missing_skus)}
    EOT
    on_failure = fail
  }
}
