locals {
  coe_creator_kit_asset_url = [for i in data.github_release.coe_creator_kit_release.assets : i.browser_download_url if i.name == "CreatorKit.zip"]
}

data "github_release" "coe_creator_kit_release" {
    repository  = "powercat-creator-kit"
    owner       = "microsoft"
    retrieve_by = var.parameters.release.creator_kit_get_latest_release == true ? "latest" : "tag"
    release_tag = var.parameters.release.creator_kit_specific_release_tag
}

resource "null_resource" "coe_creator_kit_download_solutions_zip" {
  triggers = {
    always_run = local.coe_creator_kit_asset_url[0]
  }

  provisioner "local-exec" {
    command = "wget -O ${path.module}/coe-creator-kit.zip ${local.coe_creator_kit_asset_url[0]}"
    when    = create
  }

  //TOOD: this assumes that we are running in a linux environment, consider adding support for windows
  provisioner "local-exec" {
    command = "rm -f ${path.module}/coe-creator-kit.zip"
    when    = destroy
  }

  depends_on = [ data.github_release.coe_creator_kit_release ]
}

//extract the solutions
resource "null_resource" "coe_creator_kit_extract_solutions_zip" {
  triggers = {
    always_run = local.coe_creator_kit_asset_url[0]
  }

  provisioner "local-exec" {
    command = "unzip -o ${path.module}/coe-creator-kit.zip -d ${path.module}/coe-creator-kit-extracted"
    when    = create
  }

  //TODO: this assumes that we are running in a linux environment, consider adding support for windows
  provisioner "local-exec" {
    command = "rm -rf ${path.module}/coe-creator-kit-extracted"
    when    = destroy
  }

  depends_on = [null_resource.coe_creator_kit_download_solutions_zip]
}

//because CreatorKitCore_XXXX.managed is in a specific version, we have to rename it to a fixed name
resource "null_resource" "rename_center_of_excellence_core_components_solution" {
  triggers = {
    always_run = local.coe_creator_kit_asset_url[0]
  }

  provisioner "local-exec" {
    command = <<-EOT
      cd ${path.module}/coe-creator-kit-extracted && mv CreatorKitCore_*.zip CreatorKitCore.zip
    EOT
    when    = create
  }
  depends_on = [null_resource.coe_creator_kit_extract_solutions_zip]
}