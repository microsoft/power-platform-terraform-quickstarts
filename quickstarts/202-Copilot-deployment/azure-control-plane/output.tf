output "oai_resource_name" {

  value = module.openai.openai_id
}

output "oai_api_key" {
  value = module.openai.openai_primary_key
}

# No property to grab this from so it has to be concatenated
output "search_endpoint_uri" {
  value = "https://${var.ai_search}.search.windows.net"
}

output "search_api_key" {
  value = azurerm_search_service.Quickstart-Data-Search.primary_key
}

output "storage_account_id" {
  value = azurerm_storage_account.Quickstart-Data-Storage.id
}

output "storage_account_name" {
  value = azurerm_storage_account.Quickstart-Data-Storage.name
}

output "storage_account_key" {
  value = azurerm_storage_account.Quickstart-Data-Storage.primary_access_key
}

output "storage_container_name" {
  value = azurerm_storage_container.Quickstart-Data-Container.name
}