output "resource_group" {
  value = azurecaf_name.resource_group.result
}

output "openai_account" {
  value = azurecaf_name.openai_account.result
}

output "openai_deployment" {
  value = azurecaf_name.openai_deployment.result
}

output "power_platform-environment" {
  value = azurecaf_name.power_platform_environment.result
}

output "data_storage" {
  value = azurecaf_name.quickstart_data_storage.result
}

output "data_container" {
  value = azurecaf_name.data_container.result
}

output "ai_search" {
  value = azurecaf_name.ai_search.result
}

output "copilot_name" {
  value = azurecaf_name.copilot_name.result
}

output "ai_search_datasource" {
  value = azurecaf_name.ai_search_datasource.result
}