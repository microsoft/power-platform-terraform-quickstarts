output "center_of_excellence_core_components_solution_zip_path" {
  value = "${path.module}/coe-starter-kit-extracted/CenterofExcellenceCoreComponents.zip"
  depends_on = [ null_resource.rename_center_of_excellence_core_components_solution ]
}

output "center_of_excellence_core_components_settings_file_path" {
    value = local_file.solution_settings_file.filename
}