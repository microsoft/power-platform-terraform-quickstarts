output "client_id" {
  value = azuread_application.ppadmin_application.client_id
}

output "client_secret" {
  value     = azuread_application_password.ppadmin_secret.value
  sensitive = true
}

##output "subscription_id" {
##  value = var.use_azurerm ? data.azurerm_subscription.current[0].subscription_id : null
##}

##output "tenant_id" {
##  value = var.use_azurerm ? data.azurerm_subscription.current[0].tenant_id : null
##}

##output "storage_account_name" {
##  value = var.storage_account_name
##}

##output "resource_group_name" {
##  value = var.resource_group_name
##}
