locals {
  coe_creator_kit_core_asset_url = [for i in data.github_release.coe_creator_kit_release.assets : i.browser_download_url if startswith(i.name,"CreatorKitCore_")]
  coe_creator_kit_ref_canvas_asset_url = [for i in data.github_release.coe_creator_kit_release.assets : i.browser_download_url if startswith(i.name,"CreatorKitReferencesCanvas_")]
  coe_creator_kit_ref_mda_asset_url = [for i in data.github_release.coe_creator_kit_release.assets : i.browser_download_url if startswith(i.name,"CreatorKitReferencesMDA_")]
}

data "github_release" "coe_creator_kit_release" {
    repository  = "powercat-creator-kit"
    owner       = "microsoft"
    retrieve_by = var.parameters.release.creator_kit_get_latest_release == true ? "latest" : "tag"
    release_tag = var.parameters.release.creator_kit_specific_release_tag
}

resource "null_resource" "coe_creator_kit_download_core_zip" {
  triggers = {
    always_run = local.coe_creator_kit_core_asset_url[0]
  }

  provisioner "local-exec" {
    command = "wget -O ${path.module}/coe-creator-kit.zip ${local.coe_creator_kit_core_asset_url[0]}"
    when    = create
  }

  //TOOD: this assumes that we are running in a linux environment, consider adding support for windows
  provisioner "local-exec" {
    command = "rm -f ${path.module}/coe-creator-kit.zip"
    when    = destroy
  }

  depends_on = [ data.github_release.coe_creator_kit_release ]
}

resource "null_resource" "coe_creator_kit_download_ref_canvas_zip" {
  triggers = {
    always_run = local.coe_creator_kit_ref_canvas_asset_url[0]
  }

  provisioner "local-exec" {
    command = "wget -O ${path.module}/coe-creator-kit-reference-canvas.zip ${local.coe_creator_kit_ref_canvas_asset_url[0]}"
    when    = create
  }

  //TOOD: this assumes that we are running in a linux environment, consider adding support for windows
  provisioner "local-exec" {
    command = "rm -f ${path.module}/coe-creator-kit-reference-canvas.zip"
    when    = destroy
  }

  depends_on = [ data.github_release.coe_creator_kit_release ]
}

resource "null_resource" "coe_creator_kit_download_ref_mda_zip" {
  triggers = {
    always_run = local.coe_creator_kit_ref_mda_asset_url[0]
  }

  provisioner "local-exec" {
    command = "wget -O ${path.module}/coe-creator-kit-reference-mda.zip ${local.coe_creator_kit_ref_mda_asset_url[0]}"
    when    = create
  }

  //TOOD: this assumes that we are running in a linux environment, consider adding support for windows
  provisioner "local-exec" {
    command = "rm -f ${path.module}/coe-creator-kit-reference-mda.zip"
    when    = destroy
  }

  depends_on = [ data.github_release.coe_creator_kit_release ]
}