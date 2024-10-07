# Configure the Azure Active Directory provider
provider "azuread" {
  tenant_id = var.tenant_id
}

# Generate random passwords for each user
resource "random_password" "user_passwords" {
  for_each = { for user in var.users : "${user.firstName}.${user.lastName}" => user }
  length   = 24
  special  = true
  upper    = true
  lower    = true
  numeric  = true
  override_special = "_%@#&*()-_=+[]{}|;:,.<>?"
}

# Create Azure AD users with the generated passwords
resource "azuread_user" "users" {
  for_each = { for user in var.users : "${user.firstName}.${user.lastName}" => user }

  user_principal_name   = "${each.value.firstName}.${each.value.lastName}@${var.domain}"
  display_name          = "${each.value.firstName} ${each.value.lastName}"
  mail_nickname         = "${each.value.firstName}.${each.value.lastName}"
  given_name            = each.value.firstName
  surname               = each.value.lastName
  usage_location        = "US"  # Change this to the desired location
  password              = random_password.user_passwords[each.key].result
  force_password_change = true
}

# Output the object IDs of the created users
output "user_ids" {
  value = [for user in azuread_user.users : user.object_id]
}