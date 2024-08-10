output "power-platform_environment_name" {
  value = azurecaf_name.power_platform_environment.result
}

output "copilot_name" {
  value = azurecaf_name.copilot.result
}

output "oai_resource_name" {

  value = module.openai.openai_id
}

output "oai_api_key" {
  value = module.openai.openai_primary_key
}

# No property to grab this from so it has to be concatenated
output "search_endpoint_uri" {
  value = "https://${azurerm_search_service.Quickstart-Data-Search.name}.search.windows.net"
}

output "search_api_key" {
  value = azurerm_search_service.Quickstart-Data-Search.primary_key
}

output "storage_account_id" {
  value = azurerm_storage_account.Quickstart-Data-Storage.id
}

output "storage_container_name" {
  value = azurerm_storage_container.Quickstart-Data-Container.name
}