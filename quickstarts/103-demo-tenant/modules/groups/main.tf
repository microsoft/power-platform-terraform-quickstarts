# Create an Azure AD group with configurable display name and description
resource "azuread_group" "maker_group" {
  display_name     = var.group_name
  description      = var.group_description
  security_enabled = true
  members          = var.user_ids
}

# Output the object ID of the created group
output "group_id" {
  value = azuread_group.maker_group.object_id
}
