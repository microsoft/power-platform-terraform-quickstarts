output "creator_kit_core_solution_zip_path" {
    value = "${path.module}/coe-creator-kit.zip"
    depends_on = [ null_resource.coe_creator_kit_download_core_zip ]
}

output "creator_kit_ref_canavas_solution_zip_path" {
    value = "${path.module}/coe-creator-kit-reference-canvas.zip"
    depends_on = [ null_resource.coe_creator_kit_download_ref_canvas_zip ]
}

output "creator_kit_ref_mda_solution_zip_path" {
    value = "${path.module}/coe-creator-kit-reference-mda.zip"
    depends_on = [ null_resource.coe_creator_kit_download_ref_mda_zip ]
}