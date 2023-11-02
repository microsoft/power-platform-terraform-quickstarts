output "client_id" {
  value = azuread_application.ppadmin_application.application_id
}

output "client_secret" {
  value     = azuread_application_password.ppadmin_secret.value
  sensitive = true
}

output "subscription_id" {
  value = data.azurerm_subscription.current.subscription_id
}

output "tenant_id" {
  value = data.azurerm_subscription.current.tenant_id
}

output "storage_account_name" {
  value = var.storage_account_name
}

output "resource_group_name" {
  value = var.resource_group_name
}