output "creator_kit_solution_zip_path" {
    value = "${path.module}/coe-creator-kit-extracted/CreatorKitCore.zip"
    depends_on = [ null_resource.rename_center_of_excellence_core_components_solution ]
}