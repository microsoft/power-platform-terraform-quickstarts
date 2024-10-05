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
  depends_on = [data.external.access_token]
}

# Convert the list of license SKUs to a comma-separated string
locals {
  license_skus_string = join(",", var.license_skus)
  group_assigned_plans_list = jsondecode(data.http.group_assigned_plans.response_body).value
}

# Determine which SKUs are missing from the group's assigned licenses
data "null_data_source" "missing_skus" {
  inputs = {
    license_skus_string = local.license_skus_string
    group_assigned_plans = jsonencode(local.group_assigned_plans_list)
  }

  depends_on = [data.http.group_assigned_plans]
}

data "null_data_source" "missing_skus_processed" {
  inputs = {
    missing_skus = join(",", [for sku in split(",", data.null_data_source.missing_skus.inputs.license_skus_string) : sku if !(contains([for plan in jsondecode(data.null_data_source.missing_skus.inputs.group_assigned_plans) : plan.skuId], sku))])
  }
}

# Execute the script if there are missing SKUs
resource "null_resource" "assign_license" {
  provisioner "local-exec" {
    command = "./assign_license.ps1 -groupId '${var.group_id}' -licenseSkus '${data.null_data_source.missing_skus_processed.inputs.missing_skus}'"
    interpreter = ["pwsh","-Command"]
    on_failure = fail
  }

  depends_on = [data.null_data_source.missing_skus_processed]
}

output "missing_skus" {
  value = split(",", data.null_data_source.missing_skus_processed.inputs.missing_skus)
}
