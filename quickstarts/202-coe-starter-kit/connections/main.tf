resource "null_resource" "build_from_source" {
  #count = var.parameters.release.build_from_source && !var.parameters.release.connections_exist ? 1 : 0

  provisioner "local-exec" {
    interpreter = ["pwsh", "-Command"]
    command = <<EOT
      git clone https://github.com/microsoft/powerapps-testengine.git
      cd powerapps-testengine/src
      $sourceBranches = "${var.parameters.release.source_branches}".Split(',')
      $tenantId = az account show --query tenantId --output tsv
      if ($sourceBranches.Length -eq 0) {
        dotnet build
      } else {
        foreach ($branch in $sourceBranches) {
          git checkout $branch
          dotnet build
        }
      }
      cd ../bin/Debug/PowerAppsTestEngine
      dotnet PowerAppsTestEngine.dll -i ../../../samples/portal/testPlan.fx.yaml -u browser -p powerapps.portal -e ${var.parameters.release.environment_id} -t $tenantId
    EOT
  }
}

//TODO: If not build from source use "pac test run" to execute the the testPlan to create required connections